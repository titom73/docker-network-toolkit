# Syslog-NG Docker Container

This Syslog-NG container is based on the official `balabit/syslog-ng:latest` image and is configured to receive and process syslog messages from network devices and applications.

## Features

- **Base image**: `balabit/syslog-ng:latest`
- **Network syslog reception**: UDP (port 514) and TCP (port 6601)
- **Multiple output formats**: Standard syslog and key-value pair format
- **Persistent logging**: Log files stored in `/var/log/`
- **RFC5424 compliance**: Supports modern syslog protocol

## Exposed Ports

- **514/udp**: Standard syslog UDP reception
- **601/tcp**: TCP syslog reception (legacy)
- **6514/tcp**: Secure syslog over TLS (reserved)

## Configuration

### Syslog-NG Settings

The container uses a custom `syslog-ng.conf` configuration with the following features:

#### Sources
- **s_local**: Internal syslog messages from the container
- **s_network_udp**: Network syslog via UDP on port 514
- **s_network_tcp**: Network syslog via TCP on port 6601 with RFC5424 protocol support

#### Destinations
- **d_messages**: Standard syslog format to `/var/log/messages`
- **d_messages_kv**: Key-value pair format to `/var/log/messages-kv.log` with ISO timestamp and all name-value pairs

#### Options
- **keep-hostname**: Preserves original hostname from syslog messages
- **stats-freq**: Statistics disabled (set to 0)
- **flush-lines**: Immediate flushing of log lines

## Building the Image

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
docker build -t git.as73.inetsix.net/docker/syslog-ng:latest .

# Multi-platform build
docker buildx build --platform linux/amd64,linux/arm64 -t git.as73.inetsix.net/docker/syslog-ng:latest .
```

## Usage Examples

### Basic Syslog Server

```bash
docker run -d --name syslog-server \
  -p 514:514/udp \
  -p 6601:601/tcp \
  git.as73.inetsix.net/docker/syslog-ng:latest
```

### With Persistent Log Storage

Mount the `/var/log` directory to persist logs on the host:

```bash
docker run -d --name syslog-server \
  -p 514:514/udp \
  -p 6601:601/tcp \
  -v $(pwd)/logs:/var/log \
  git.as73.inetsix.net/docker/syslog-ng:latest
```

### Access Log Files

```bash
# View real-time logs
docker exec -it syslog-server tail -f /var/log/messages

# View key-value format logs
docker exec -it syslog-server tail -f /var/log/messages-kv.log

# Or from host (if volume mounted)
tail -f ./logs/messages
```

### With ContainerLab

Example ContainerLab topology configuration:

```yaml
name: logging-lab
mgmt:
  network: logging-network
  ipv4-subnet: 192.168.20.0/24

topology:
  nodes:
    syslog-server:
      image: git.as73.inetsix.net/docker/syslog-ng:latest
      mgmt-ipv4: 192.168.20.10
      kind: linux
      publish:
        - udp/514
        - tcp/6601
      binds:
        - ./logs:/var/log:rw
```

### Network Device Configuration

```eos
logging host 192.168.20.10
logging source-interface Management1
logging level informational
logging format hostname fqdn
```

### Docker Compose Example

```yaml
version: '3.8'
services:
  syslog-ng:
    image: git.as73.inetsix.net/docker/syslog-ng:latest
    container_name: syslog-server
    ports:
      - "514:514/udp"
      - "6601:601/tcp"
    volumes:
      - ./logs:/var/log
      - ./config/syslog-ng.conf:/etc/syslog-ng/syslog-ng.conf:ro
    restart: unless-stopped
```

## Log File Formats

### Standard Syslog Format (`/var/log/messages`)

```bash
2025-06-13T10:30:45.123+00:00 router1 BGP: %BGP-5-ADJCHANGE: neighbor 10.0.0.1 Up
2025-06-13T10:30:46.456+00:00 switch1 STP: %SPANTREE-5-ROOTCHANGE: Root Changed for vlan 100
```

### Key-Value Format (`/var/log/messages-kv.log`)

```bash
2025-06-13T10:30:45.123 router1 HOST=router1 PROGRAM=BGP MESSAGE=%BGP-5-ADJCHANGE: neighbor 10.0.0.1 Up
2025-06-13T10:30:46.456 switch1 HOST=switch1 PROGRAM=STP MESSAGE=%SPANTREE-5-ROOTCHANGE: Root Changed for vlan 100
```

## Custom Configuration

### Override Default Configuration

```bash
docker run -d --name syslog-server \
  -p 514:514/udp \
  -p 6601:601/tcp \
  -v $(pwd)/custom-syslog-ng.conf:/etc/syslog-ng/syslog-ng.conf:ro \
  -v $(pwd)/logs:/var/log \
  git.as73.inetsix.net/docker/syslog-ng:latest
```

### Custom Configuration Example

```conf
@version: 4.2
@include "scl.conf"

options {
  keep-hostname(yes);
  stats-freq(3600);
  flush-lines(100);
};

source s_network {
  network(
    transport("udp")
    port(514)
  );
};

destination d_network_logs {
  file("/var/log/network-devices.log"
    template("$ISODATE $HOST $PROGRAM: $MESSAGE\n")
  );
};

filter f_network_devices {
  host("router*" or "switch*" or "firewall*");
};

log {
  source(s_network);
  filter(f_network_devices);
  destination(d_network_logs);
};
```

## Log Rotation

For production use, implement log rotation to prevent disk space issues:

```bash
# Create logrotate configuration
cat > logrotate.conf << EOF
/path/to/logs/messages {
    daily
    rotate 30
    compress
    delaycompress
    missingok
    notifempty
    postrotate
        docker exec syslog-server pkill -HUP syslog-ng
    endscript
}
EOF

# Add to crontab
echo "0 2 * * * /usr/sbin/logrotate /path/to/logrotate.conf" | crontab -
```

## Monitoring and Troubleshooting

### Check Container Status

```bash
# Container logs
docker logs syslog-server

# Real-time syslog-ng process
docker exec -it syslog-server ps aux | grep syslog-ng
```

### Test Syslog Reception

```bash
# Send test UDP syslog message
echo '<14>Jun 13 10:30:45 testhost myapp: Test message' | nc -u -w1 localhost 514

# Send test TCP syslog message
echo '<14>Jun 13 10:30:45 testhost myapp: Test TCP message' | nc -w1 localhost 6601
```

### Debug Configuration

```bash
# Test configuration syntax
docker exec -it syslog-server syslog-ng --syntax-only

# Run in foreground with debug
docker exec -it syslog-server syslog-ng -F -d
```

## Security Considerations

### Firewall Configuration

```bash
# Allow syslog UDP
ufw allow 514/udp

# Allow syslog TCP
ufw allow 6601/tcp

# Restrict to specific networks
ufw allow from 192.168.0.0/16 to any port 514 proto udp
```

### TLS Configuration

For secure syslog transmission, configure TLS:

```conf
source s_network_tls {
  network(
    transport("tls")
    port(6514)
    tls(
      key-file("/etc/ssl/private/syslog-ng.key")
      cert-file("/etc/ssl/certs/syslog-ng.crt")
      ca-dir("/etc/ssl/certs")
    )
  );
};
```

## Performance Tuning

### High-Volume Environments

```conf
options {
  keep-hostname(yes);
  stats-freq(0);
  flush-lines(1000);
  use-dns(no);
  dns-cache(no);
  log-fifo-size(10000);
};
```

### Resource Limits

```bash
docker run -d --name syslog-server \
  --memory=512m \
  --cpus=1.0 \
  -p 514:514/udp \
  -p 6601:601/tcp \
  -v $(pwd)/logs:/var/log \
  git.as73.inetsix.net/docker/syslog-ng:latest
```

## Integration Examples

### With ELK Stack

Forward logs to Elasticsearch:

```conf
destination d_elasticsearch {
  elasticsearch2(
    client-mode("http")
    url("http://elasticsearch:9200")
    index("syslog-${YEAR}.${MONTH}.${DAY}")
    type("syslog")
  );
};
```

### With Grafana Loki

Forward logs to Loki:

```conf
destination d_loki {
  http(
    url("http://loki:3100/loki/api/v1/push")
    headers("Content-Type: application/json")
    body('{"streams":[{"stream":{"host":"${HOST}","job":"syslog"},"values":[["${S_UNIXTIME}000000000","${MESSAGE}"]]}]}')
  );
};
```

## Support

For more information about Syslog-NG configuration:
- [Official Syslog-NG Documentation](https://www.syslog-ng.com/technical-documents/doc/syslog-ng-open-source-edition/3.38/administration-guide)
- [Syslog-NG GitHub Repository](https://github.com/syslog-ng/syslog-ng)
- [RFC5424 - The Syslog Protocol](https://tools.ietf.org/html/rfc5424)
