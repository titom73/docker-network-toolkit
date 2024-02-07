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


$ docker push titom73/freeradius:0.3.0
The push refers to repository [docker.io/titom73/freeradius]
11d8e95eba2c: Pushed
a5d47849ff0e: Mounted from freeradius/freeradius-server
923b92b7a7a8: Mounted from freeradius/freeradius-server
0f580cf8f6a3: Mounted from freeradius/freeradius-server
16542a8fc3be: Mounted from freeradius/freeradius-server
6597da2e2e52: Mounted from freeradius/freeradius-server
977183d4e999: Mounted from freeradius/freeradius-server
c8be1b8f4d60: Mounted from freeradius/freeradius-server
0.3.0: digest: sha256:09aed4d155b3737f214b74fb19473d1e75572f7546a585ddee3f02c616bac484 size: 1989
```

## Run commands

### Manage container

```shell
$ docker run -d -t --name freeradius -p 1812:1812/udp -p 1813:1813/udp titom73/freeradius:latest

$ docker logs freeradius

$ docker rm -f freeradius
```

### Test container

```shell
$ radtest ansible cvpuser 172.17.0.2 0 testing123
```

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

```txt
aradmin  Cleartext-Password := "aradmin"
         Auth-Type := Accept,
         Service-Type := NAS-Prompt-User,
         Arista-AVpair = "shell:priv-lvl=15",
         Arista-AVpair = "shell:cvp-roles=network-admin"
```
