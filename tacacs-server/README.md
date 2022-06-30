# TACACS+ Docker Image

This image is a built version of [tac_plus](http://www.pro-bono-publico.de/projects/),
a TACACS+ implementation written by Marc Huber.

Various configuration options and components were taken from an existing docker image repos which can be found here:

- https://github.com/lfkeitel/docker-tacacs-plus
- https://github.com/dchidell/docker-tacacs


## Usage

By default all logs (including detailed information on authorization and authentication) are sent to stdout, meaning they're available to view via `docker logs` once the container is operational. This log contains all AAA information.

A log file is also generated with less verbosity (i.e. no debug information). This can be found at `/var/log/tac_plus.log` within the container. This can either be exported via a docker volume or read directly to console by cat or tailing the file via docker exec. E.g. `docker exec <containerid / name>  tail -f /var/log/tac_plus.log`

TACACS+ uses port 49. This is exposed by the container, but will require forwarding to the host if the default bridged networking is used using `-p 49:49`

## Configuration

The `tac_user.cfg` file should be modified and passed into the container via a docker volume using `-v /path/to/tac_user.cfg:/etc/tac_plus/tac_user.cfg`

If base configuration changes are required, the `tac_base.cfg` file can be altered and included as a docker volume following the above syntax.

Various configuration defaults exist (defined in `tac_user.cfg`)

- __TACACS Key:__ `ciscotacacskey`
- __Priv 15 User (IOS):__ `iosadmin` _password:_ `cisco`
- __Priv 0 User (IOS):__ `iosuser` _password:_ `cisco`
- __Network Admin (NXOS):__ `nxosadmin` _password:_ `cisco`
- __Network User (NXOS):__ `nxosuser` _password:_ `cisco`
- __Read-write User (ACI):__ `aciadmin` _password:_ `cisco`
- __Read-only User (ACI):__ `aciro` _password:_ `cisco`
- __Show User:__ `showuser` _password:_ `cisco`

## Examples

Example - Running the default container for a quick test and inspecting the logs:

```bash
docker run -it --rm -p 49:49 titom73/tacacs
```

Example - Deamonise the container and live-view basic logs after a while:

```bash
docker run -itd --name=tacacs -p 49:49 titom73/tacacs
docker exec tacacs tail -f /var/log/tac_plus.log
```

Example - Deamonise the container and live-view all logs after a while:

```bash
docker run -itd --name=tacacs -p 49:49 titom73/tacacs
docker logs -f tacacs
```

Example - Daemonise the container with a modified config file and live-view all logs after a while:

```bash
docker run -itd --name=tacacs -v /path/to/my/config/tac_user.cfg:/etc/tac_plus/tac_user.cfg:ro -p 49:49 titom73/tacacs
docker logs -f tacacs
```
