# TACACS+ Docker Image

This image is a built version of
[tac_plus](http://www.pro-bono-publico.de/projects/), a TACACS+ implementation
written by Marc Huber.

## Tags

`latest`, `ubuntu`, `ubuntu-<build-date>` - Latest version based on Ubuntu
18.04.

`alpine`, `alpine-<build-date>` - Latest version based on Alpine 3.9.

## Building

Docker engine 17.06+ is required to build this image because it uses a multi-stage build. To build run: `make`. Add the argument `alpine` or `ubuntu` to build a specific image.

```bash
# Build Ubuntu version
make ubuntu

# Build Alpine
make alpine

# Build Alpine, Ubuntu and TAG images
make all
```

## Using

To run with the default configuration:

```bash
ddocker run -itd --network tacacs-testing --name=tacacs -p 49:49 git.as73.inetsix.net/docker/tacacs_plus:alpine
```

> [!WARNING]
> The default configuration has a user with the username:password of `eosadmin:eosadmin` and the enable password is set to enable. Obviously, don't use this configuration in production.

Available users:

- username: `eosadmin` member of `eos-priv-15`
- username: `eosuser` member of `eos-priv-1`
- username: `showuser` member of `show-user`

All passwords are set to `arista`

The configuration is located at [`/etc/tac_plus/tac_plus.cfg`](./tac_plus.sample.cfg). If you wish to use a custom configuration, simply overwrite it in a derived image or use a volume mount.

```bash
docker run -itd --network tacacs-testing --name=tacacs \
    -v ${PWD}/tac_user.cfg:/etc/tac_plus/tac_plus.cfg\
    -p 49:49 git.as73.inetsix.net/docker/tacacs_plus:alpine
```

By default logs go to stdout.

Port 49 is exposed as the server port.

## EOS Configuration

Basic setup to apply:

```EOS
tacacs-server host <TACACS_PLUS_IP> vrf default key 0 arista
tacacs-server policy unknown-mandatory-attribute ignore
aaa authentication login default group tacacs+ local
aaa authentication enable default group tacacs+ local
aaa authorization exec default group tacacs+ local
aaa authorization commands all default group tacacs+ local
aaa accounting commands all default start-stop group tacacs+
```

## Configuration

Configuration documentation can be found [here](http://www.pro-bono-publico.de/projects/unpacked/doc/tac_plus.pdf).
