# Network-Multitool

__Initial image comes from [@hellt Multitool image](https://github.com/hellt/Network-MultiTool)__

A (**multi-arch**) multitool for container/network testing and troubleshooting. The main docker image is based on Alpine Linux.

The container image contains lots of tools, as well as a `nginx` web server, which listens on port `80` and `443` by default. The web server helps to run this container-image in a straight-forward way, so you can simply `exec` into the container and use various tools.

## Supported platforms:
* linux/386
* linux/amd64
* linux/arm/v7
* linux/arm64

## Variants / image tags:
* **latest**, minimal ( The main/default **'minimal'** image - Alpine based )
* extra

Remember, this *multitool* is purely a troubleshooting tool, and should be used as such. It is not designed to abuse openshift (or any system's) security, nor should it be used to do so.


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
* tcpdump
* jq
* bash

**Size:** 16 MB compressed, 38 MB uncompressed

## Tools included in "extra":
All tools from "minimal", plus:
* iperf3
* ethtool, mii-tool, route
* nmap
* ss
* tshark
* ssh client, lftp client, rsync, scp
* netcat (nc), socat
* ApacheBench (ab)
* mysql & postgresql client
* git

**Size:** 64 MB compressed, 220 MB uncompressed


**Note:** The SSL certificates are generated for "localhost", are self signed, and placed in `/certs/` directory. During your testing, ignore the certificate warning/error. While using curl, you can use `-k` to ignore SSL certificate warnings/errors.

------

# How to use this image?
## How to use this image in normal **container/pod network** ?

### Docker:
```
$ docker run  -d titom73/network-multitool
```

Then:

```
$ docker exec -it container-name /bin/bash
```


### Kubernetes:

Create single pod - without a deployment:
```
$ kubectl run multitool --image=titom73/network-multitool
```

Create a deployment:
```
$ kubectl create deployment multitool --image=titom73/network-multitool
```

Then:
```
$ kubectl exec -it pod-name /bin/bash
```

**Note:** You can pass additional parameter `--namespace=<your-desired-namespace>` to the above kubectl commands.


## How to use this image on **host network** ?

Sometimes you want to do testing using the **host network**.  This can be achieved by running the multitool using host networking.


### Docker:
```
$ docker run --network host -d titom73/multitool
```

**Note:** If port 80 and/or 443 are already busy on the host, then use pass the extra arguments to multitool, so it can listen on a different port, as shown below:

```
$ docker run --network host -e HTTP_PORT=1180 -e HTTPS_PORT=11443 -d titom73/network-multitool
```

### Kubernetes:
For Kubernetes, there is YAML/manifest file `multitool-daemonset.yaml` in the `kubernetes` directory, that will run an instance of the multitool on all hosts in the cluster using host networking.

```
$ kubectl apply -f kubernetes/multitool-daemonset.yaml
```

**Notes:**
* You can pass additional parameter `--namespace=<your-desired-namespace>` to the above kubectl command.
* Due to a possibility of something (some service) already listening on port 80 and 443 on the worker nodes, the `daemonset` is configured to run multitool on port `1180` and `11443`. You can change this in the YAML file if you want.


## Configure network interfaces

### Single homed interface in access mode

```bash
$ ifconfig eth1 10.1.10.11 netmask 255.255.255.0
```

### Single homed interface in trunk mode

```bash
$ ip link add link eth1 name eth1.110 type vlan id 110
$ ip link set dev eth1.110 up

$ ip -d link show eth1.110
2: eth1.110@eth1: <BROADCAST,MULTICAST> mtu 9500 qdisc noop state DOWN mode DEFAULT group default qlen 1000
    link/ether aa:c1:ab:f0:1d:2f brd ff:ff:ff:ff:ff:ff promiscuity 0 minmtu 0 maxmtu 65535
    vlan protocol 802.1Q id 110 <REORDER_HDR> addrgenmode eui64 numtxqueues 1 numrxqueues 1 gso_max_size 65536 gso_max_segs 65535

$ ifconfig eth1.110 10.1.10.11 netmask 255.255.255.0
```

### Teaming

container must be started with environment variable `TMODE` set to one of this values:

- `LACP`
- `STATIC`
- `active-backup`

If used in containerlabs environment, this can be done with following knob:

```yaml
topology:
  kinds:
    ceos:
      image: arista/ceos:4.27.1F
    linux:
      image: titom73/network-multitool:extra
  nodes:
    client11:
      kind: linux
      mgmt_ipv4: 10.73.255.191
      env:
        TMODE: lacp
```

Shell configuration

```bash
# Configure team0 for vlan110
$ vconfig add team0 110
$ ifconfig team0.110 10.1.10.11 netmask 255.255.255.0
$ ip link set team0.110 up
```


# Configurable HTTP and HTTPS ports:
There are times when one may want to join this (multitool) container to another container's IP namespace for troubleshooting, or on the host network. This is true for both Docker and Kubernetes platforms. During that time if the container in question is a web server (nginx, apache, etc), or a reverse-proxy (traefik, nginx, haproxy, etc), then network-multitool cannot join it in the same IP namespace on Docker, and similarly it cannot join the same pod on Kubernetes. This happens because network multitool also runs a web server on port 80 (and 443), and this results in port conflict on the same IP address. To help in this sort of troubleshooting, there are two environment variables **HTTP_PORT** and **HTTPS_PORT** , which you can use to provide the values of your choice instead of 80 and 443. When the container starts, it uses the values provided by you/user to listen for incoming connections. Below is an example:

```
$ docker run -e HTTP_PORT=1180 -e HTTPS_PORT=11443 \
    -p 1180:1180 -p 11443:11443 -d local/network-multitool
4636efd4660c2436b3089ab1a979e5ce3ae23055f9ca5dc9ffbab508f28dfa2a


$ docker ps
CONTAINER ID        IMAGE                     COMMAND                  CREATED             STATUS              PORTS                                                             NAMES
4636efd4660c        local/network-multitool   "/docker-entrypoint.…"   4 seconds ago       Up 3 seconds        80/tcp, 0.0.0.0:1180->1180/tcp, 443/tcp, 0.0.0.0:11443->11443/tcp   recursing_nobel
6e8b6ed8bfa6        nginx                     "nginx -g 'daemon of…"   56 minutes ago      Up 56 minutes       80/tcp                                                            nginx


$ curl http://localhost:1180
Inetsix Network MultiTool (with NGINX) - 4636efd4660c - 172.17.0.3/16 - HTTP: 1180 , HTTPS: 11443


$ curl -k https://localhost:11443
Inetsix Network MultiTool (with NGINX) - 4636efd4660c - 172.17.0.3/16 - HTTP: 1180 , HTTPS: 11443
```

If these environment variables are absent/not-provided, the container will listen on normal/default ports 80 and 443.
