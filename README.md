
# Docker images repository for network labs

## Overview

A simple repository with various Dockerfile to build different network services:

- A [multitool](multitool) image to be used as network client:

```bash
# Latest small image
docker pull titom73/multitool:latest
docker run -d --rm titom73/multitool:latest
86........
docker exec -it 86 bash
```

- A simple [SSH Jumphost](ssh-server) to use with mysocket.io & containerlabs:

```bash
docker pull titom73/ssh-server:latest
docker run --rm \
  --publish=1337:22 \
  --env KEYPAIR_LOGIN=true \
  --volume /path/to/authorized_keys:/root/.ssh/authorized_keys \
  titom73/ssh-server
```

- A simple [Freeradius](freeradius-server) server:

```bash
docker pull titom73/radius:latest
```

## License

Code is under Apache2 License
