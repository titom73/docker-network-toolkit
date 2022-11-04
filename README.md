
# Docker images repository for network labs

## Overview

A simple repository with various Dockerfile to build different network services:

- A [multitool](multitool) image to be used as network client:

```bash
# Latest small image
docker pull titom73/multitool
```

- A simple [SSH Jumphost](mysocket-io-ssh-client) to use with mysocket.io & containerlabs: ``

```bash
docker pull titom73/mysocket-io-ssh-client:0.3.0
```

- A simple [Freeradius](freeradius-server) server:

```bash
docker pull titom73/radius:0.3.0
```

## License

Code is under Apache2 License
