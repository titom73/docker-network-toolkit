
# Docker Network Toolkit

A comprehensive collection of Docker containers for network testing, labs, and troubleshooting.

## 🚀 Features

- **Multi-architecture support**: All images built for `linux/amd64` and `linux/arm64`
- **Automated builds**: GitHub Actions workflows for CI/CD
- **Security scanning**: Automated vulnerability and quality checks
- **Unified build system**: Single Makefile to manage all projects
- **Flexible registry support**: Configurable container registry and naming

## 📦 Available Images

All images are available on GitHub Container Registry: `ghcr.io/titom73/`

- **`multitool`**: Network debugging and testing tools
- **`ssh-server`**: SSH server for remote access testing
- **`freeradius-server`**: RADIUS authentication server
- **`freeradius-client`**: RADIUS client tools
- **`syslog`**: Syslog server for log collection
- **`tacacs-server`**: TACACS+ authentication server

## 🛠️ Using the unified Makefile

From the repository root, you can control all images with a single Makefile:

```bash
# Show available commands and projects
make help
make projects

# Build one project (two equivalent forms)
make build PROJECT=multitool
make multitool.build

# Multi-arch build + push
make buildx PROJECT=freeradius-server

# Push (only if the project defines a push target)
make syslog.push
```

See [COMMANDS.md](./COMMANDS.md) for more examples and details.

## Build images

- A [multitool](multitool) image to be used as network client:

```bash
# Build image from repo root
make multitool.build

# Latest small image
docker run -d --rm git.as73.inetsix.net/docker/multitool:latest
86........
docker exec -it 86 ash
```

- A simple [Freeradius](freeradius-server) server:

```bash
# Build image from repo root
make freeradius-server.build

# Run latest dev image
docker run -d --name freeradius \
  -p 1812:1812/udp \
  -p 1813:1813/udp \
  git.as73.inetsix.net/docker/freeradius:latest
```

- A Remote [Syslog](/syslog/) server:

```bash
# Build image from repo root
make syslog.build

# Run container
docker run -d --name syslog-server \
  -p 514:514/udp \
  git.as73.inetsix.net/docker/syslog:dev
```

- A [TACACS+](./tacacs-server/) docker image:

```bash
# Build image from repo root
make tacacs-server.build

# Run latest dev image
docker run -itd \
  --network tacacs-testing \
  --name=tacacs \
  -p 49:49 \
  git.as73.inetsix.net/docker/tacplus:dev
```

- A simple [SSH Jumphost](ssh-server) to use with mysocket.io & containerlabs:

```bash
docker pull git.as73.inetsix.net/docker/ssh-server:latest
docker run --rm \
  --publish=1337:22 \
  --env KEYPAIR_LOGIN=true \
  --volume /path/to/authorized_keys:/root/.ssh/authorized_keys \
  git.as73.inetsix.net/docker/ssh-server:latest
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

### 📦 Using Pre-built Images

```bash
# Pull latest images from GitHub Container Registry
docker pull ghcr.io/titom73/multitool:latest
docker pull ghcr.io/titom73/ssh-server:latest
docker pull ghcr.io/titom73/freeradius-server:latest

# Use specific versions
docker pull ghcr.io/titom73/multitool:v1.0.0
```

### 🔧 Container Registry Configuration

Default registry is GitHub Container Registry (`ghcr.io`), but you can use any registry:

```bash
# Use custom registry
make build PROJECT=multitool REGISTRY_PREFIX=your-registry.com/namespace

# Use Docker Hub
make build PROJECT=multitool REGISTRY_PREFIX=docker.io/yourusername
```

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

To build this image locally using the root Makefile:

```bash
make ssh-server.build
```

## Documentation

For the full list of commands, variables, and examples, see the root-level documentation: [COMMANDS.md](./COMMANDS.md)

## License

Code is under Apache2 License
