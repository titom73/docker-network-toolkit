
# Docker Network Toolkit

A comprehensive collection of Docker containers for network testing, labs, and troubleshooting. This toolkit provides essential networking services and debugging tools designed for containerized environments, network labs, and testing scenarios.

## 🚀 Features

- **Multi-architecture support**: All images built for `linux/amd64` and `linux/arm64`
- **Automated builds**: GitHub Actions workflows for CI/CD
- **Security scanning**: Automated vulnerability and quality checks
- **Unified build system**: Single Makefile to manage all projects
- **Flexible registry support**: Configurable container registry and naming
- **Ready-to-use**: Pre-configured services with sensible defaults

## 📦 Available Images

All images are available on GitHub Container Registry: `ghcr.io/titom73/`

### 🛠️ Network Tools

#### **multitool** - Network Debugging Swiss Army Knife

Alpine-based container packed with essential network debugging and testing tools.

**Includes**: curl, wget, dig, nslookup, ping, traceroute, netcat, tcpdump, iperf3, nmap, and more.

```bash
docker pull ghcr.io/titom73/multitool:latest
```

#### **ssh-server** - SSH Jump Host

Lightweight SSH server perfect for jump hosts, tunneling, and remote access testing.

**Features**: Key-based authentication, configurable users, containerlab integration.

```bash
docker pull ghcr.io/titom73/ssh-server:latest
```

### 🔐 Authentication Services

#### **freeradius-server** - RADIUS Authentication Server

Complete FreeRADIUS server for network authentication and authorization.

**Features**: Pre-configured for testing, supports multiple authentication methods, CoA testing.

```bash
docker pull ghcr.io/titom73/freeradius-server:latest
```

#### **freeradius-client** - RADIUS Client Tools

RADIUS client utilities for testing RADIUS servers and authentication flows.

**Includes**: radtest, radclient, and other RADIUS testing tools.

```bash
docker pull ghcr.io/titom73/freeradius-client:latest
```

#### **tacacs-server** - TACACS+ Authentication Server

TACACS+ server for device authentication and command authorization.

**Features**: Pre-configured for network device testing, supports command authorization.

```bash
docker pull ghcr.io/titom73/tacacs-server:latest
```

### � Log Management

#### **syslog** - Syslog Server

Centralized syslog server for collecting and managing network device logs.

**Features**: UDP/TCP syslog reception, configurable logging levels, log rotation.

```bash
docker pull ghcr.io/titom73/syslog:latest
```

## 🏁 Getting Started

### Quick Start with Pre-built Images

1. **Pull and run a network debugging container:**

```bash
docker run -it --rm ghcr.io/titom73/multitool:latest
# Now you have access to all network debugging tools
```

2. **Set up a RADIUS server for testing:**

```bash
docker run -d --name radius-server \
  -p 1812:1812/udp \
  -p 1813:1813/udp \
  ghcr.io/titom73/freeradius-server:latest
```

3. **Create an SSH jump host:**

```bash
docker run -d --name ssh-jump \
  -p 2222:22 \
  -e KEYPAIR_LOGIN=true \
  -v ~/.ssh/authorized_keys:/root/.ssh/authorized_keys \
  ghcr.io/titom73/ssh-server:latest
```

### Using with Docker Compose

Create a `docker-compose.yml` for a complete testing environment:

```yaml
version: '3.8'
services:
  multitool:
    image: ghcr.io/titom73/multitool:latest
    container_name: network-tools
    stdin_open: true
    tty: true

  radius:
    image: ghcr.io/titom73/freeradius-server:latest
    container_name: radius-server
    ports:
      - "1812:1812/udp"
      - "1813:1813/udp"

  syslog:
    image: ghcr.io/titom73/syslog:latest
    container_name: syslog-server
    ports:
      - "514:514/udp"
```

Run with: `docker-compose up -d`

## 🔨 Manual Build Instructions

### Prerequisites

- Docker Engine
- Make (for unified Makefile)
- Git

### Building Individual Images

Clone the repository and use the unified Makefile:

```bash
# Clone the repository
git clone https://github.com/titom73/docker-network-toolkit.git
cd docker-network-toolkit

# Show available projects and commands
make help
make projects

# Build a specific image
make build PROJECT=multitool
make build PROJECT=freeradius-server
make build PROJECT=ssh-server

# Alternative syntax (equivalent)
make multitool.build
make freeradius-server.build
make ssh-server.build
```

### Multi-Architecture Builds

Build for multiple architectures (requires Docker Buildx):

```bash
# Build and push multi-arch image
make buildx PROJECT=multitool

# Build for specific platforms
docker buildx build --platform linux/amd64,linux/arm64 -t my-multitool ./multitool/
```

### Custom Registry Configuration

Build and push to your own registry:

```bash
# Use custom registry
make build PROJECT=multitool REGISTRY_PREFIX=your-registry.com/namespace

# Use Docker Hub
make build PROJECT=multitool REGISTRY_PREFIX=docker.io/yourusername

# Build and push
make buildx PROJECT=multitool REGISTRY_PREFIX=your-registry.com/namespace
```

### Building All Images

```bash
# Build all projects
make build-all

# Or build each individually
for project in multitool ssh-server freeradius-server freeradius-client syslog tacacs-server; do
  make build PROJECT=$project
done
```

### Advanced Build Options

```bash
# Build with custom tag
docker build -t custom-multitool:v1.0 ./multitool/

# Build with build arguments
docker build --build-arg VERSION=latest -t multitool ./multitool/

# Build without cache
docker build --no-cache -t multitool ./multitool/
```

## 🚀 Automated Builds and Deployment

This repository uses GitHub Actions for automated building and deployment:

### 🏗️ Build Strategy

- **Smart builds**: Only builds projects with actual changes
- **Multi-architecture**: Supports `linux/amd64` and `linux/arm64`
- **Secure**: Images scanned for vulnerabilities before deployment
- **Fast**: Uses build cache for optimal performance

### 🏷️ Image Tagging

- **`latest`**: Latest stable version from main branch
- **`main`**: Latest commit on main branch
- **`v*`**: Git tag releases (e.g., `v1.2.3`)

## 📚 Documentation

- **[COMMANDS.md](COMMANDS.md)**: Complete Makefile usage guide
- **[.github/README.md](.github/README.md)**: GitHub Actions workflows documentation

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test locally with `make build PROJECT=<project>`
5. Submit a pull request

Automated workflows will test your changes and provide feedback on security and quality.

## 📜 License

This project is licensed under the Apache License 2.0 - see the individual project directories for specific licensing information.
