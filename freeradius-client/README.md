# FreeRadius Client Docker image

- [Docker Hub repository](https://hub.docker.com/repository/docker/git.as73.inetsix.net/docker/radtest/general)

Basic Alpine image with freeradius/radtest for radius testing.


## Run commands

### Manage container

```shell
$ docker run --rm -it git.as73.inetsix.net/docker/radtest:latest aradmin aradmin 192.168.10.2 0 testing123
```

### Containerlab integration

```yaml
topology:
  nodes:
    radtest:
      image: git.as73.inetsix.net/docker/radtest:${IMAGE_VERSION:=latest}
      kind: linux
      mgmt-ipv4: 192.168.10.3
      entrypoint: ash
```

## radtest Usage

### AAA example

```shell
radtest cvpuser cvpuser 192.168.10.2 0 testing123

Sent Access-Request Id 227 from 0.0.0.0:58428 to 192.168.10.2:1812 length 77
        User-Name = "cvpuser"
        User-Password = "cvpuser"
        NAS-IP-Address = 192.168.10.3
        NAS-Port = 0
        Message-Authenticator = 0x00
        Cleartext-Password = "cvpuser"
Received Access-Reject Id 227 from 192.168.10.2:1812 to 192.168.10.3:58428 length 38
        Message-Authenticator = 0x5c373c10ca5414f794fbcfa21de741e3
(0) -: Expected Access-Accept got Access-Reject
```

### Mac based with Calling-station-id

```bash
# Request
cat << EOF | radclient -x 192.168.10.2 auth testing123
  User-Name = 6894244B56EB
  User-Password = 6894244B56EB
  NAS-Port = 0
  Calling-Station-Id = 00-11-22-33-44-55
EOF

# Response
Sent Access-Request Id 8 from 0.0.0.0:59048 to 192.168.10.2:1812 length 77
        User-Name = "6894244B56EB"
        User-Password = "6894244B56EB"
        NAS-Port = 0
        Calling-Station-Id = "00-11-22-33-44-55"
        Cleartext-Password = "6894244B56EB"
Received Access-Accept Id 8 from 192.168.10.2:1812 to 192.168.10.3:59048 length 111
        Message-Authenticator = 0x6a7ad7476ae48b6e2864b8a82fe59549
        Reply-Message = "Device with MAC Address 00-11-22-33-44-55 authorized for network access"
```