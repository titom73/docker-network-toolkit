# TACACS+ Docker Image

Tacacs+ docker image for lab purpose

> [!NOTE]
> This image is not yet built in the repository, please built it manually

## Usage

TBD

## Pre-configured users

- `admin` with no password - member of `superuser`
- `cvpadmin` with no password - member of `superuser`
- `testuser1` member of `restricted-priv-lvl-15`
- `testuser2` member of `restricted-priv-lvl-1`

## Debugging values for lab

Values that can be used in `CMD` with `-d` option:

```bash
docker run <options> git.as73.inetsix.net/docker/tacacs -d 8 -d 16
```

- `2`:       configuration parsing debugging
- `4`:       fork(1) debugging
- `8`:       authorization debugging
- `16`:      authentication debugging
- `32`:      password file processing debugging
- `64`:      accounting debugging
- `128`:     config file parsing & lookup
- `256`:     packet transmission/reception
- `512`:     encryption/decryption
- `1024`:    MD5 hash algorithm debugging
- `2048`:    very low level encryption/decryption
- `32768`:   max session debugging
- `65536`:   lock debugging

## Examples

### Example - Deamonise the container and live-view basic logs after a while:

```bash
# Run container
docker run -itd --name=tacacs -v /path/to/my/config/tac_user.cfg:/etc/tac_plus/tac_user.cfg:ro -p 49:49 git.as73.inetsix.net/docker/tacacs

# Show TACACs logs
docker exec tacacs tail -f /var/log/tac_plus.log

# Show accounting logs
docker exec tacacs tail -f /var/log/tac_plus.acct
```

### Example with docker-compose

```yaml
services:
  tacacs:
    build: tacacs
    container_name: lab-tacacs
    restart: unless-stopped
    command:
      - '-d'
      - '8'
      - '-d'
      - '16'
      # Value   Meaning
      # 2       configuration parsing debugging
      # 4       fork(1) debugging
      # 8       authorization debugging
      # 16      authentication debugging
      # 32      password file processing debugging
      # 64      accounting debugging
      # 128     config file parsing & lookup
      # 256     packet transmission/reception
      # 512     encryption/decryption
      # 1024    MD5 hash algorithm debugging
      # 2048    very low level encryption/decryption
      # 32768   max session debugging
      # 65536   lock debugging
    volumes:
      - ./tacacs/tac_plus.cfg:/etc/tac_plus/tac_plus.cfg:ro
    ports:
      - 49:49
    networks:
      - clab
```
