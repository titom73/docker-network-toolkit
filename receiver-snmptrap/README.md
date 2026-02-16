# SNMP Trap Receiver

A simple containerized SNMP trap receiver for demo and lab purposes. Receives SNMP traps and displays them in a human-readable format via `docker logs`.

## Quick Start

```bash
# Run the container (using host network for reliable UDP reception)
docker run -d --name snmptrap --network host \
    ghcr.io/titom73/docker-snmptrap-receiver:latest \
    bin/snmptrap-receiver --port 1162

# View received traps
docker logs -f snmptrap

# Send a test trap
snmptrap -v 2c -c public localhost:1162 '' 1.3.6.1.6.3.1.1.5.1
```

## Usage

### Docker

```bash
# Basic usage with host network (recommended for macOS/Docker Desktop)
docker run -d --name snmptrap --network host \
    ghcr.io/titom73/docker-snmptrap-receiver:latest \
    bin/snmptrap-receiver --port 1162

# With custom community string
docker run -d --name snmptrap --network host \
    ghcr.io/titom73/docker-snmptrap-receiver:latest \
    bin/snmptrap-receiver --port 1162 --community mystring

# Using port mapping (Linux only, may not work on macOS/Windows)
docker run -d --name snmptrap -p 162:162/udp \
    ghcr.io/titom73/docker-snmptrap-receiver:latest
```

> **Note:** On macOS and Windows with Docker Desktop, UDP port forwarding can be unreliable. Using `--network host` with a non-privileged port (>1024) is recommended.

### Local Installation

```bash
pip install .
snmptrap-receiver --port 1162 --community public
```

### CLI Options

| Option | Default | Description |
|--------|---------|-------------|
| `--port`, `-p` | 162 | UDP port to listen on |
| `--community`, `-c` | public | SNMP community string |
| `--debug`, `-d` | false | Enable debug mode |

## Testing

Send a test trap using `snmptrap` (requires net-snmp):

```bash
snmptrap -v 2c -c public localhost:1162 '' 1.3.6.1.6.3.1.1.5.1
```

Or use the provided test script:

```bash
./tests/send-test-trap.sh localhost 1162 public
```

## Output Example

```
======================================================================
🔊 SNMP Trap Receiver
======================================================================
  Listening on:  0.0.0.0:1162/udp
  Community:     public
  Debug mode:    disabled
======================================================================
Waiting for traps...

══════════════════════════════════════════════════════════════════════
📥 SNMP Trap received at 2024-01-15 14:32:45
──────────────────────────────────────────────────────────────────────
  Source: 127.0.0.1:54321
──────────────────────────────────────────────────────────────────────
  Variable Bindings:
    1.3.6.1.2.1.1.3.0
      (sysUpTime)
      = 123456
    1.3.6.1.6.3.1.1.4.1.0
      (snmpTrapOID)
      = 1.3.6.1.6.3.1.1.5.1
══════════════════════════════════════════════════════════════════════
```

## Build

```bash
docker build -t snmptrap-receiver:latest .
```

## Supported SNMP Versions

- SNMPv1
- SNMPv2c

## License

[Apache 2.0](LICENSE)

