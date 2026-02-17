# Docker Compose - Monitoring Stack

This Docker Compose stack provides a complete monitoring and logging solution for network labs and testing environments.

## Services

### 🗂️ Syslog Server
- **Image**: `git.as73.inetsix.net/docker/syslog-ng:latest`
- **Ports**: 
  - `514/udp` - Standard syslog UDP
  - `6601/tcp` - TCP syslog
- **Volumes**: `$HOME/logs:/var/log` - Persistent log storage
- **Purpose**: Centralized syslog collection from network devices

### 🪝 Webhook Receiver
- **Image**: `git.as73.inetsix.net/docker/webhook-receiver:latest`
- **Port**: `8282` - HTTP webhook endpoint
- **Purpose**: Receive and display webhook notifications for testing

### 📬 SNMP Trap Receiver
- **Image**: `git.as73.inetsix.net/docker/snmptrap-receiver:latest`
- **Port**: `1162/udp` - SNMP trap reception (non-privileged port)
- **Network**: Host mode for reliable UDP reception
- **Purpose**: Receive and display SNMP traps from network devices

## Quick Start

### Start All Services

```bash
cd compose
docker-compose up -d
```

### Check Status

```bash
docker-compose ps
```

### View Logs

```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f syslog
docker-compose logs -f webhook
docker-compose logs -f snmptrap
```

### Stop Services

```bash
docker-compose down
```

## Usage Examples

### Syslog

Configure your network device to send logs to the Docker host:

```eos
! Arista EOS
logging host <docker-host-ip>
logging source-interface Management1
logging level informational
```

View received logs:

```bash
# Real-time logs
tail -f $HOME/logs/messages

# Or via docker
docker-compose exec syslog tail -f /var/log/messages
```

### Webhook

Send a test webhook:

```bash
curl -X POST http://localhost:8282/receiver \
  -H 'Content-Type: application/json' \
  -d '{"event": "test", "message": "Hello from network device"}'
```

View received webhooks:

```bash
docker-compose logs -f webhook
```

### SNMP Trap

Send a test SNMP trap:

```bash
snmptrap -v 2c -c public localhost:1162 '' 1.3.6.1.6.3.1.1.5.1
```

View received traps:

```bash
docker-compose logs -f snmptrap
```

## Configuration

### Environment Variables

You can customize the log directory by setting the `HOME` environment variable before starting:

```bash
export HOME=/custom/path
docker-compose up -d
```

### Custom Syslog Configuration

To use a custom syslog-ng configuration:

1. Create your custom config file: `./config/syslog-ng.conf`
2. Update `docker-compose.yml`:

```yaml
services:
  syslog:
    volumes:
      - ${HOME}/logs:/var/log
      - ./config/syslog-ng.conf:/etc/syslog-ng/syslog-ng.conf:ro
```

### Change Webhook Port

Edit `docker-compose.yml` to change the webhook port:

```yaml
services:
  webhook:
    ports:
      - "9090:80"  # Change 9090 to your desired port
```

### Change SNMP Trap Port

Edit the command in `docker-compose.yml`:

```yaml
services:
  snmptrap:
    command: bin/snmptrap-receiver --port 2162 --community mycommunity
```

## Network Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Docker Host                              │
│                                                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │   Syslog     │  │   Webhook    │  │  SNMP Trap   │      │
│  │   Server     │  │   Receiver   │  │   Receiver   │      │
│  │              │  │              │  │              │      │
│  │  514/udp     │  │  8282/tcp    │  │  1162/udp    │      │
│  │  6601/tcp    │  │              │  │  (host mode) │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
│         │                 │                  │              │
│         └─────────────────┴──────────────────┘              │
│                    monitoring network                       │
└─────────────────────────────────────────────────────────────┘
                           │
                           │
                    Network Devices
                  (routers, switches)
```

## Troubleshooting

### Syslog not receiving messages

1. Check firewall rules:
   ```bash
   sudo ufw allow 514/udp
   sudo ufw allow 6601/tcp
   ```

2. Verify container is running:
   ```bash
   docker-compose ps syslog
   ```

3. Test with netcat:
   ```bash
   echo '<14>Test message' | nc -u localhost 514
   ```

### Webhook not responding

1. Check if port 8282 is accessible:
   ```bash
   curl http://localhost:8282/receiver
   ```

2. Check container logs:
   ```bash
   docker-compose logs webhook
   ```

### SNMP Trap not receiving

1. Verify host network mode is working:
   ```bash
   docker-compose ps snmptrap
   ```

2. Test with snmptrap command:
   ```bash
   snmptrap -v 2c -c public localhost:1162 '' 1.3.6.1.6.3.1.1.5.1
   ```

## License

Apache 2.0

