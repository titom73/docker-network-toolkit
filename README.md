
# Docker Network Toolkit

Collection of Docker images for network testing, troubleshooting, and lab environments. Each image is designed for integration with [ContainerLab](https://containerlab.dev/) and network device testing, with a focus on Arista EOS.

## Available Registries

All images are published to **two registries**:

- **GitHub Container Registry (Public)**: `ghcr.io/titom73/*`
- **Forgejo Container Registry (Private)**: `git.as73.inetsix.net/docker/*`

## Available Images

### 🛠️ [Multitool](multitool/)

Multi-arch network troubleshooting container with 40+ tools (nginx, FRR, SSH, tcpdump, etc.)

```bash
# GitHub Container Registry
docker pull ghcr.io/titom73/multitool:latest
docker run -d --rm ghcr.io/titom73/multitool:latest

# Forgejo Container Registry
docker pull git.as73.inetsix.net/docker/multitool:latest
```

**Platforms**: linux/386, amd64, arm/v7, arm64, ppc64le

---

### 🔐 [FreeRADIUS Server](freeradius-server/)

RADIUS server with Arista VSA dictionary for AAA testing

```bash
# GitHub Container Registry
docker pull ghcr.io/titom73/freeradius:latest

# Forgejo Container Registry
docker pull git.as73.inetsix.net/docker/freeradius:latest
```

**Platforms**: linux/amd64, arm64

---

### 📡 [FreeRADIUS Client](freeradius-client/)

RADIUS testing client (radtest) for lab validation

```bash
# GitHub Container Registry
docker pull ghcr.io/titom73/radtest:latest

# Forgejo Container Registry
docker pull git.as73.inetsix.net/docker/radtest:latest
```

**Platforms**: linux/amd64, arm64

---

### 🔑 [TACACS+ Server](tacacs-server/)

TACACS+ authentication server (Ubuntu and Alpine variants)

```bash
# GitHub Container Registry - Ubuntu (default)
docker pull ghcr.io/titom73/tacacs-plus:latest
docker pull ghcr.io/titom73/tacacs-plus:ubuntu

# GitHub Container Registry - Alpine
docker pull ghcr.io/titom73/tacacs-plus:alpine

# Forgejo Container Registry
docker pull git.as73.inetsix.net/docker/tacacs-plus:alpine
docker run -itd --network tacacs-testing --name=tacacs -p 49:49 \
  git.as73.inetsix.net/docker/tacacs-plus:alpine
```

**Platforms**: linux/amd64, arm64

---

### 🚪 [SSH Server](ssh-server/)

Lightweight SSH jump host for mysocket.io and ContainerLab

```bash
# GitHub Container Registry
docker pull ghcr.io/titom73/ssh-server:latest
docker run --rm \
  --publish=1337:22 \
  --env KEYPAIR_LOGIN=true \
  --volume /path/to/authorized_keys:/root/.ssh/authorized_keys \
  ghcr.io/titom73/ssh-server:latest

# Forgejo Container Registry
docker pull git.as73.inetsix.net/docker/ssh-server:latest
```

**Platforms**: linux/386, amd64, arm/v7, arm64, ppc64le

---

### 🪝 [Webhook Receiver](receiver-webhook/)

Simple webhook receiver for testing and demo purposes

```bash
# GitHub Container Registry
docker pull ghcr.io/titom73/webhook-receiver:latest
docker run -d -p 8282:80 ghcr.io/titom73/webhook-receiver:latest

# Forgejo Container Registry
docker pull git.as73.inetsix.net/docker/webhook-receiver:latest
```

**Platforms**: linux/amd64, arm64

---

### 📬 [SNMP Trap Receiver](receiver-snmptrap/)

SNMP trap receiver for lab and demo environments

```bash
# GitHub Container Registry
docker pull ghcr.io/titom73/snmptrap-receiver:latest
docker run -d --network host ghcr.io/titom73/snmptrap-receiver:latest

# Forgejo Container Registry
docker pull git.as73.inetsix.net/docker/snmptrap-receiver:latest
```

**Platforms**: linux/amd64, arm64

---

## Building Locally

**Default registry**: Forgejo (`git.as73.inetsix.net/docker/*`)

Each image has its own `Makefile` with dual-registry support:

```bash
# Build locally (uses Forgejo registry by default)
cd <image-directory>
make build

# Push to GitHub Container Registry
make push-github

# Push to Forgejo Container Registry
make push-forgejo

# Push to both registries
make push-all

# Override registry/namespace (example: build for GitHub)
make build REGISTRY=ghcr.io NAMESPACE=titom73 IMAGE_TAG=v1.0
```

