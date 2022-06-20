
# Docker images repository for network labs

A simple repository with various Dockerfile to build different network services:

- A [multitool](multitool) image to be used as network client:

```bash
# Latest small image
docker pull titom73/network-multitool:0.3.0

# With extra tools
docker pull titom73/network-multitool:extra-0.3.0
```

- A simple [SSH Jumphost](mysocket-io-ssh-client) to use with mysocket.io & containerlabs: ``

```bash
docker pull titom73/mysocket-io-ssh-client:0.3.0
```

- A simple [Freeradius](freeradius-server) server:

```bash
docker pull titom73/radius:0.3.0
```
