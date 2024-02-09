# FreeRadius Docker image

- Generated from: [freeradius/freeradius-server](https://hub.docker.com/r/freeradius/freeradius-server/)
- [Docker Hub repository](https://hub.docker.com/repository/docker/titom73/freeradius/general)

Arista Radius directory:

```txt
ATTRIBUTE    Arista-AVPair                       1     string
ATTRIBUTE    Arista-User-Priv-Level              2     integer
ATTRIBUTE    Arista-User-Role                    3     string
ATTRIBUTE    Arista-CVP-Role                     4     string
ATTRIBUTE    Arista-Command                      5     string
ATTRIBUTE    Arista-WebAuth                      6     integer
ATTRIBUTE    Arista-BlockMac                     7     string
ATTRIBUTE    Arista-UnblockMac                   8     string
ATTRIBUTE    Arista-PortFlap                     9     integer
ATTRIBUTE    Arista-Captive-Portal               10    string

VALUE    Arista-WebAuth            start            1
VALUE    Arista-WebAuth            complete         2
```

Container runs freeradius in debug mode (`-X`) to print out requests and responses in `docker logs`

## Build Commands

```shell
$ docker build -t titom73/freeradius:latest .
Sending build context to Docker daemon  5.632kB
Step 1/2 : FROM freeradius/freeradius-server:latest
latest: Pulling from freeradius/freeradius-server
5bed26d33875: Pull complete
f11b29a9c730: Pull complete
930bda195c84: Pull complete
78bf9a5ad49e: Pull complete
2de2cd3fd5d1: Pull complete
d5350feee5dd: Pull complete
59cc082ab365: Pull complete
Digest: sha256:21c8bfa904d866c0f206210d941553498973bc80800a65e68a348aca4727cd1d
Status: Downloaded newer image for freeradius/freeradius-server:latest
 ---> 4b030320a0c3
Step 2/2 : COPY raddb/ /etc/raddb/
 ---> f67bd5b2e15a
Successfully built f67bd5b2e15a
Successfully tagged titom73/freeradius:0.3.0
```

## Run commands

### Manage container

```shell
$ docker run -d -t --name freeradius -p 1812:1812/udp -p 1813:1813/udp titom73/freeradius:latest

$ docker logs freeradius --follow

$ docker rm -f freeradius
```

### Test container

```shell
$ radtest ansible cvpuser 172.17.0.2 0 testing123
```

Or use [titom73/radtest](../freeradius-client/) container

### Containerlab integration

```yaml
topology:
  nodes:
    radius:
      image: titom73/freeradius:latest
      mgmt_ipv4: 172.16.0.2
      kind: linux
      binds:
        - radius_authorize:/etc/raddb/mods-config/files/authorize
# ...
  links:
    - endpoints: ["leaf1:eth2", "radius:eth1"]
```

### freeradius Authorize example

#### AAA Example

Configured under [`raddb/mods-config/files/authorize`](raddb/mods-config/files/authorize)

```txt
aradmin  Cleartext-Password := "aradmin"
         Auth-Type := Accept,
         Service-Type := NAS-Prompt-User,
         Arista-AVpair = "shell:priv-lvl=15",
         Arista-AVpair = "shell:cvp-roles=network-admin"
```
