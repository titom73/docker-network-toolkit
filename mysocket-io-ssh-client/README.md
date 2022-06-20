# SSH Client for mysocket-io

A small Alpine linux with SSH client to act as mysocket-io client to share remote access to lab using containerlab.

```yaml
topology:
  nodes:
    management:
        image: titom73/mysocket-io-ssh-remote:0.2.0
        mgmt_ipv4: 192.168.1.10
        kind: linux
        publish:
        - tcp/22/inetsix.net
    mysocketio:
      kind: mysocketio
      image: ghcr.io/hellt/mysocketctl:0.5.0
      binds:
        - ${HOME}/.mysocketio_token:/root/.mysocketio_token
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

## Build Process

Makefile with following options:

- `build`:  Build image locally
- `help`:  Display help message (*: main entry points / []: part of an entry point)
- `push`:  Push image to remote registry
- `test`:  Start a container in daemon mode

