# Network-Multitool

__Initial image comes from [@hellt Multitool image](https://github.com/hellt/Network-MultiTool)__
## Tools included in "latest, minimal":
* apk package manager
* Nginx Web Server (port `80`, port `443`) - with customizable ports!
* awk, cut, diff, find, grep, sed, vi editor, wc
* curl, wget
* dig, nslookup
* ip, ifconfig, route
* traceroute, tracepath, mtr, tcptraceroute (for layer 4 packet tracing)
* ping, arp, arping
* ps, netstat
* gzip, cpio, tar
* telnet client
* ssh-server
* tcpdump
* jq
* bash

## Tools included in "extra":
All tools from "minimal", plus:
* iperf3
* ethtool, mii-tool, route
* nmap
* ss
* tshark
* ssh-server
* ssh client, lftp client, rsync, scp
* netcat (nc), socat
* ApacheBench (ab)
* mysql & postgresql client
* git

## Username & password for ssh
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
