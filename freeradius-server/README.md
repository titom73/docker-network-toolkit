# FreeRadius Docker image

- Generated from: [freeradius/freeradius-server](https://hub.docker.com/r/freeradius/freeradius-server/)
- [Local repository](https://git.as73.inetsix.net/docker/-/packages/container/freeradius/latest)

Arista Radius directory:

```txt
ATTRIBUTE    Arista-AVPair                       1     string
ATTRIBUTE    Arista-User-Priv-Level              2     integer
ATTRIBUTE    Arista-User-Role                    3     string
ATTRIBUTE    Arista-CVP-Role                     4     string
ATTRIBUTE    Arista-Command                      5     string
ATTRIBUTE    Arista-WebAuth                      6     integer
ATTRIBUTE    Arista-BlockMac                     7     string
ATTRIBUTE    Arista-UnblockMac                   8     string
ATTRIBUTE    Arista-PortFlap                     9     integer
ATTRIBUTE    Arista-Captive-Portal               10    string

VALUE    Arista-WebAuth            start            1
VALUE    Arista-WebAuth            complete         2
```

Container runs freeradius in debug mode (`-X`) to print out requests and responses in `docker logs`

## Available tags

- `latest`: Run with latest version of Freeradius
- `3.2.5`: Run with Freeradius `3.2.5`

## Run commands

### Manage container

```shell
$ docker run -d -t --name freeradius -p 1812:1812/udp -p 1813:1813/udp git.as73.inetsix.net/docker/freeradius:latest

$ docker logs freeradius --follow

$ docker rm -f freeradius
```

### Test container

```shell
$ radtest cvpuser cvpuser 192.168.10.2 0 testing123
```

Or use [`git.as73.inetsix.net/docker/radtest:latest`](../freeradius-client/) container

### Containerlab integration

```yaml
topology:
  nodes:
    radius:
      image: git.as73.inetsix.net/docker/freeradius:latest
      mgmt_ipv4: 172.16.0.2
      kind: linux
      binds:
        - radius_authorize:/etc/raddb/mods-config/files/authorize

# ...
  links:
    - endpoints: ["leaf1:eth2", "radius:eth1"]
```

### freeradius usage examples

#### AAA Example

Configured under [`raddb/mods-config/files/authorize`](raddb/mods-config/files/authorize)

> [!NOTE]
> This file is already part of the image build. It is recommended to mount your own authentication file.

__Usage in a containerlab topology__

```yaml
topology:
  nodes:
    radius:
      image: git.as73.inetsix.net/docker/freeradius:latest
      mgmt_ipv4: 172.16.0.2
      kind: linux
      binds:
        - raddb/clients.conf:/etc/raddb/clients.conf
        - radius_authorize:/etc/raddb/mods-config/files/authorize

# ...
  links:
    - endpoints: ["leaf1:eth2", "radius:eth1"]
```

__Username definition example__

```txt
aradmin  Cleartext-Password := "aradmin"
         Auth-Type := Accept,
         Service-Type := NAS-Prompt-User,
         Arista-AVpair = "shell:priv-lvl=15",
         Arista-AVpair = "shell:cvp-roles=network-admin"
```

#### MAC Based Authorization

Based on [FreeRadius documentation](https://wiki.freeradius.org/guide/Mac-Auth)

> [!IMPORTANT]
> This configuration breaks the AAA configuration.

- List of authorized MAC addresses: [`/etc/raddb/authorized_macs`](raddb/authorized_macs)
- MAC Address authorization configuration: [`/etc/raddb/mods-config/files/authorize`](raddb/mods-config/files/authorize)
- MAC Address authorization processor: [`/etc/raddb/mods-enabled/authorized_macs`](raddb/mods-config/files/authorized_macs)
- Default site configuration: [`/etc/raddb/sites-available/default`](raddb/sites-available/default)

__Usage in a containerlab topology__

```yaml
topology:
  nodes:
    radius:
      image: git.as73.inetsix.net/docker/freeradius:latest
      mgmt_ipv4: 172.16.0.2
      kind: linux
      binds:
        - raddb/clients.conf:/etc/raddb/clients.conf
        - raddb/authorized_macs:/etc/raddb/authorized_macs
        - raddb/mods-config/files/authorize:/etc/raddb/mods-config/files/authorize
        - raddb/mods-config/files/authorized_macs:/etc/raddb/mods-enabled/authorized_macs
        - raddb/sites-available/default:/etc/raddb/sites-available/default

# ...
  links:
    - endpoints: ["leaf1:eth2", "radius:eth1"]
```

__Radtest example to send `Calling-Station-Id`__

```bash
cat << EOF | radclient -x 192.168.10.2 auth testing123
  User-Name = 6894244B56EB
  User-Password = 6894244B56EB
  NAS-Port = 0
  Calling-Station-Id = 00-11-22-33-44-55
EOF
```