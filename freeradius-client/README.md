# FreeRadius Client Docker image

- [Docker Hub repository](https://hub.docker.com/repository/docker/titom73/radtest/general)

Basic Alpine image with freeradius/radtest for radius testing.


## Run commands

### Manage container

```shell
$ docker run --rm -it titom73/radtest:latest aradmin aradmin 192.168.10.2 0 testing123
```

### Containerlab integration

```yaml
topology:
  nodes:
    radtest:
      image: titom73/radtest:${IMAGE_VERSION:=latest}
      kind: linux
      mgmt-ipv4: 192.168.10.3
      entrypoint: ash
```
