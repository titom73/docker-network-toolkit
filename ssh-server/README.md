# SSH Client for mysocket-io

> Feature in [containerlab is not working](https://containerlab.dev/manual/published-ports/) since my-socket.io has been rebranded border0

A small Alpine linux with SSH client to act as mysocket-io client to share remote access to lab using containerlab.


## How to use image

### Docker CLI example



### Containerlab example

```yaml
topology:
  nodes:
    management:
        image: titom73/ssh-server
        mgmt_ipv4: 192.168.1.10
        kind: linux
        ports:
          - 1122:22
```

Username and password are configured like this:

- Username: `root`
- Password: `password123`

It can be changed with Docker ARG build arguments:

```docker
# Arguement for Password
ARG PASSWORD=root
ARG USERNAME=<your password>
```

Or by using Makefile:

```bash
$ make build DOCKER_ARGS='--build-arg PASSWORD=<your-password-secure>'
```
