# multitool

__Initial image comes from [@hellt Multitool image](https://github.com/hellt/multitool)__

## Tools included in image:

* apk package manager
* ip, ifconfig, route, ethtool, mii-tool, route
* [FRR framework](https://docs.frrouting.org/en/latest/setup.html) with configuration available under `/etc/frr/frr.conf`
* tcpdump, tshark, traceroute, tracepath, mtr, tcptraceroute, nmap
* ping, arp, arping, hping3, iperf3
* Nginx Web Server (port `80`, port `443`)
* curl, wget, dig, nslookup
* ssh-server, ssh client, lftp client, rsync, scp, telnet-client
* awk, cut, diff, find, grep, sed, vi editor, wc
* ps, netstat, gzip, cpio, tar
* jq, bash, git

## Supported platforms

* linux/amd64
* linux/arm64

```bash
make buildx
```

## Username & password for ssh

Username and password are configured like this:

* Username: `root`
* Password: `password123`

It can be changed with Docker ARG build arguments:

```bash
# Arguement for Password
ARG PASSWORD=your-password
```

Or by using Makefile:

```bash
make build DOCKER_ARGS='--build-arg PASSWORD=<your-password-secure>'
```

## Configure network interfaces

### Single homed interface in access mode

```bash
ifconfig eth1 10.1.10.11 netmask 255.255.255.0
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
      image: titom73/multitool:extra
  nodes:
    client11:
      kind: linux
      mgmt_ipv4: 10.73.255.191
      env:
        TMODE: lacp
      exec:
        - sleep 10
        - vconfig add bond0 103
        - ifconfig bond0.103 10.1.3.13 netmask 255.255.255.0
        - ip route del default
        - ip route add default via 10.1.3.1
        - vconfig add bond0 200
        - ifconfig bond0.200 10.1.200.13 netmask 255.255.255.0
```

Shell configuration

```bash
# Configure team0 for vlan110
$ vconfig add team0 110
$ ifconfig team0.110 10.1.10.11 netmask 255.255.255.0
$ ip link set team0.110 up
```

## Configurable HTTP and HTTPS ports:

Below is an example:

```bash
# Start container with custom ports
$ docker run -e HTTP_PORT=1180 -e HTTPS_PORT=11443 \
    -p 1180:1180 -p 11443:11443 -d local/multitool
4636efd4660c2436b3089ab1a979e5ce3ae23055f9ca5dc9ffbab508f28dfa2a

# List running containers with exposed ports
$ docker ps
CONTAINER ID        IMAGE                     COMMAND                  CREATED             STATUS              PORTS                                                             NAMES
4636efd4660c        local/multitool   "/docker-entrypoint.…"   4 seconds ago       Up 3 seconds        80/tcp, 0.0.0.0:1180->1180/tcp, 11443/tcp, 0.0.0.0:11443->11443/tcp   recursing_nobel
6e8b6ed8bfa6        nginx                     "nginx -g 'daemon of…"   56 minutes ago      Up 56 minutes       80/tcp                                                            nginx

# Test connectivity for HTTP traffic on custom port
$ curl http://localhost:1180
Inetsix Network MultiTool (with NGINX) - 4636efd4660c - 172.17.0.3/16 - HTTP: 1180 , HTTPS: 11443

# Test connectivity for HTTPS traffic on custom port
$ curl -k https://localhost:11443
Inetsix Network MultiTool (with NGINX) - 4636efd4660c - 172.17.0.3/16 - HTTP: 1180 , HTTPS: 11443
```

If these environment variables are absent/not-provided, the container will listen on normal/default ports 80 and 443.

## How to use this image on __host network__ ?

Sometimes you want to do testing using the __host network__.  This can be achieved by running the multitool using host networking.

### Docker:

```bash
docker run --network host -d titom73/multitool
```

__Note:__ If port 80 and/or 443 are already busy on the host, then use pass the extra arguments to multitool, so it can listen on a different port, as shown below:

```bash
docker run --network host -e HTTP_PORT=1180 -e HTTPS_PORT=11443 -d titom73/multitool
```

### Kubernetes:

For Kubernetes, there is YAML/manifest file [`multitool-daemonset.yaml`](https://github.com/titom73/docker-network-toolkit/blob/main/multitool/kubernetes/multiool-daemonset.yml) in the `kubernetes` directory, that will run an instance of the multitool on all hosts in the cluster using host networking.

```bash
kubectl apply -f multitool-daemonset.yaml
```

__Notes:__

* You can pass additional parameter `--namespace=<your-desired-namespace>` to the above kubectl command.
* Due to a possibility of something (some service) already listening on port 80 and 443 on the worker nodes, the `daemonset` is configured to run multitool on port `1180` and `11443`. You can change this in the YAML file if you want.
