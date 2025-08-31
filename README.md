
# Docker images repository for network labs

## Overview

A simple repository with various Dockerfile to build different network services:

## Using the unified Makefile

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
  git.as73.inetsix.net/docker/ssh-server
```

To build this image locally using the root Makefile:

```bash
make ssh-server.build
```

## Documentation

For the full list of commands, variables, and examples, see the root-level documentation: [COMMANDS.md](./COMMANDS.md)

## License

Code is under Apache2 License
