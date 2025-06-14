
# Docker images repository for network labs

## Overview

A simple repository with various Dockerfile to build different network services:

- A [multitool](multitool) image to be used as network client:

```bash
# Build image
cd multitool
make build

# Latest small image
docker run -d --rm git.as73.inetsix.net/docker/multitool:latest
86........
docker exec -it 86 ash
```

- A simple [Freeradius](freeradius-server) server:

```bash
# Build image
cd freeradius-server
make build

# Run latest dev image
docker run -d --name freeradius \
  -p 1812:1812/udp \
  -p 1813:1813/udp \
  git.as73.inetsix.net/docker/freeradius:latest
```

- A Remote [Syslog](/syslog/) server:

```bash
# Build image
cd syslog
make build

# Run container
docker run -d --name syslog-server \
  -p 514:514/udp \
  git.as73.inetsix.net/docker/syslog:dev
```

- A [TACACS+](./tacacs-server/) docker image:

```bash
# Build image
cd tacacs-server
make build

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

## License

Code is under Apache2 License
