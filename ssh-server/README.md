# SSH Client for mysocket-io

A small Alpine linux with SSH client.

## Features
* Always installs the latest OpenSSH-Version available for Alpine
* Password of `root`-user can be changed when starting the container using --env
* You can choose between ssh-keypair- and password auth

## Basic Usage
### Authentication by password

```
$ docker run --rm \
  --publish=1337:22 \
  --env ROOT_PASSWORD=MyRootPW123 \
  titom73/ssh-server
```

After the container is up you are able to ssh in it as root with the in --env provided password for `root`-user.

```
$ ssh root@mydomain.tld -p 1337
```

### Authentication by ssh-keypair

```
$ docker run --rm \
  --publish=1337:22 \
  --env KEYPAIR_LOGIN=true \
  --volume /path/to/authorized_keys:/root/.ssh/authorized_keys \
  titom73/ssh-server
```

After the container is up you are able to ssh in it as root with a private-key which matches the provided public-key in authorized_keys for `root`-user.

```
$ ssh root@localhost -p 1337 -i /path/to/private_key
```

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

> Publish feature in [containerlab is not working](https://containerlab.dev/manual/published-ports/) since my-socket.io has been rebranded border0

## Default credentials

Username and password are configured like this:

- Username: `root`
- Password: `password123`

