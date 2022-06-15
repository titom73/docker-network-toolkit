# SSH Client for mysocket-io

A small Alpine linux with SSH client to act as mysocket-io client to share remote access to lab.

```yaml
topology:
  nodes:
    management:
        image: titom73/mysocket-io-ssh-client:0.2.0
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

- Username: `ansible`
- Password: `ansible`

It can be changed with Docker ARG build arguments:

```docker
# Arguement for Password
ARG PASSWORD=ansible
ARG USERNAME=ansible
```
