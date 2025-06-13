# FreeRADIUS Server Docker Image

This FreeRADIUS container is based on the official `freeradius/freeradius-server:latest-alpine` image and is preconfigured for network authentication testing with Arista equipment support.

## Features

- **Base image**: `freeradius/freeradius-server:latest-alpine`
- **Arista dictionary**: Included for Arista-specific attributes support
- **Additional tools**: `freeradius-utils` for testing and diagnostics
- **Exposed ports**: 1812 (Authentication), 1813 (Accounting)
- **Debug mode**: Starts in debug mode by default (`-X`)

## Building the image

### With Make

```bash
# Local build
make build

# Multi-architecture build
make buildx

# Push to registry
make push
```

### With Docker

```bash
# Basic build
docker build -t git.as73.inetsix.net/docker/freeradius:latest .

# Multi-platform build
docker buildx build --platform linux/amd64,linux/arm64 -t git.as73.inetsix.net/docker/freeradius:latest .
```

## Configuration

### Configured users

The `raddb/mods-config/files/authorize` file contains the following users:

- **cvpadmin** / **cvpadmin** - Privilege level 15, VLAN 100
- **cvpuser** / **cvpuser** - Privilege level 15
- **demoradius** / **demoredius** - Privilege level 15
- **aradmin** / **aradmin** - Admin with CVP roles
- **fc:bd:67:0f:1c:d1** - MAC authentication, VLAN 100
- **fc:bd:67:0f:1c:d2** - MAC authentication, VLAN 228

### RADIUS clients

The `raddb/clients.conf` file allows all clients with the secret `testing123`:

```conf
client 0.0.0.0/0 {
    secret = testing123
    shortname = all
}
```

### Supported Arista attributes

The Arista dictionary includes the following attributes:

- `Arista-AVPair` - Attribute-value pairs
- `Arista-User-Priv-Level` - User privilege level
- `Arista-CVP-Role` - CloudVision Portal roles
- `Arista-PortFlap` - Port flapping control
- `Arista-Port-Shutdown` - Port shutdown
- `Arista-Interface-Profile` - Interface profile
- And many more...

## Usage

### Simple startup

```bash
docker run -d --name freeradius \
  -p 1812:1812/udp \
  -p 1813:1813/udp \
  git.as73.inetsix.net/docker/freeradius:latest
```

### With custom configuration

```bash
docker run -d --name freeradius \
  -p 1812:1812/udp \
  -p 1813:1813/udp \
  -v $(pwd)/raddb/mods-config/files/authorize:/etc/raddb/mods-config/files/authorize:ro \
  git.as73.inetsix.net/docker/freeradius:latest
```

### With ContainerLab

The `radius.clab.yml` file provides a ContainerLab integration example:

```yaml
name: radius
mgmt:
  network: radius-testing
  ipv4-subnet: 192.168.10.0/24

topology:
  nodes:
    radius:
      image: git.as73.inetsix.net/docker/freeradius:latest
      mgmt-ipv4: 192.168.10.2
      kind: linux
      publish:
        - udp/1812
        - udp/1813
      binds:
        - raddb/mods-config/files/authorize:/etc/raddb/mods-config/files/authorize:ro
```

Deployment:

```bash
sudo containerlab deploy -t radius.clab.yml
```

## Authentication testing

### Basic test with radtest

```bash
# Test a configured user
radtest cvpadmin cvpadmin 192.168.10.2 0 testing123

# Test with MAC user
radtest "fc:bd:67:0f:1c:d1" "fc:bd:67:0f:1c:d1" 192.168.10.2 0 testing123
```

### Test with radclient

```bash
# Authentication with additional attributes
cat << EOF | radclient -x 192.168.10.2 auth testing123
  User-Name = cvpadmin
  User-Password = cvpadmin
  NAS-Port = 0
  Calling-Station-Id = 00-11-22-33-44-55
EOF
```

## CoA (Change of Authorization) testing

The server supports CoA requests for dynamic actions:

### Port Flap

```bash
radclient -f coa_tests/coa_portflap.txt -x 192.168.10.2:3799 coa testing123
```

Contents of `coa_portflap.txt` file:

```txt
User-Name = fc:bd:67:0f:1c:d1
NAS-IP-Address=192.168.10.2
Arista-PortFlap=1
```

### Port Shutdown

```bash
radclient -f coa_tests/coa_portshutdown.txt -x 192.168.10.2:3799 coa testing123
```

Contents of `coa_portshutdown.txt` file:

```txt
User-Name = fc:bd:67:0f:1c:d1
NAS-IP-Address=192.168.10.2
Arista-Port-Shutdown=30
```

## Debugging and logs

### Log access

```bash
# Real-time logs
docker logs -f freeradius

# Or with Make
make log RADIUS_CONTAINER=freeradius
```

### Shell into container

```bash
# Shell access
docker exec -it freeradius sh

# Or with Make
make sh RADIUS_CONTAINER=freeradius
```

### Debug testing

The server starts in debug mode by default (`-X`), displaying all RADIUS transactions in detail.

## Customization

### Modifying users

Edit the `raddb/mods-config/files/authorize` file:

```conf
# New user
newuser Cleartext-Password := "password"
        Arista-AVPair = "shell:priv-lvl=15",
        Service-Type = NAS-Prompt-User,
        Tunnel-Private-Group-Id=200
```

### Modifying clients

Edit the `raddb/clients.conf` file to restrict access:

```conf
client 192.168.1.0/24 {
    secret = my-secret-key
    shortname = network-devices
}
```

### Advanced configuration

FreeRADIUS configuration files are in `/etc/raddb/`:

- `sites-available/default` - Virtual server configuration
- `mods-config/files/authorize` - User database
- `clients.conf` - Authorized RADIUS clients

## Integration with Arista equipment

### Arista switch configuration

```eos
aaa authentication login default group radius local
aaa authorization exec default group radius local
aaa accounting exec default start-stop group radius

radius-server host 192.168.10.2 key testing123
```

### Typical response attributes

For an Arista admin:

```txt
Arista-AVPair = "shell:priv-lvl=15"
Arista-CVP-Role = "network-admin"
Service-Type = NAS-Prompt-User
```

## Troubleshooting

### Common issues

1. **Port already in use**: Check that no other service is using ports 1812/1813
2. **Incorrect secret**: Verify that the secret matches between client and server
3. **Firewall**: Ensure UDP ports 1812/1813 are open

### Status verification

```bash
# Check that container listens on correct ports
docker exec freeradius netstat -ulnp

# Connectivity test
nc -u 192.168.10.2 1812 < /dev/null
```

## Environment variables

The container can be configured with the following variables:

- `IMAGE_VERSION`: Image version (default: `latest`)

## Support

For more information about FreeRADIUS, see:

- [Official FreeRADIUS documentation](https://freeradius.org/documentation/)
- [FreeRADIUS Wiki](https://wiki.freeradius.org/)
- [Arista AAA documentation](https://www.arista.com/en/um-eos/eos-aaa-services)
