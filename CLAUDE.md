# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Collection of Docker images for network testing, troubleshooting, and lab environments. Each subdirectory is a standalone Docker image project with its own Dockerfile and Makefile. Primary use case is integration with [ContainerLab](https://containerlab.dev/) for network device testing, with a focus on Arista EOS.

## Build Commands

Each image is built independently from its own directory. There is no top-level build system. All Makefiles support **dual-registry** builds.

```bash
# Build any image (run from the image's directory)
make build

# Push to GitHub Container Registry
make push-github

# Push to Forgejo Container Registry
make push-forgejo

# Push to both registries
make push-all

# tacacs-server has separate alpine/ubuntu targets
cd tacacs-server && make alpine   # or: make ubuntu
cd tacacs-server && make all      # builds both, then tags

# Override registry/namespace/tag
make build REGISTRY=ghcr.io NAMESPACE=titom73 IMAGE_TAG=v1.0
```

## Repository Structure

All images are published to **two registries**:
- **GitHub Container Registry**: `ghcr.io/titom73/*`
- **Forgejo Container Registry**: `git.as73.inetsix.net/docker/*`

| Directory | GitHub Image | Forgejo Image | Base | Purpose |
|---|---|---|---|---|
| `multitool/` | `ghcr.io/titom73/multitool` | `git.as73.inetsix.net/docker/multitool` | Alpine 3.16 | Network troubleshooting container (40+ tools, nginx, FRR, SSH) |
| `freeradius-server/` | `ghcr.io/titom73/freeradius` | `git.as73.inetsix.net/docker/freeradius` | freeradius-server:3.2.5-alpine | RADIUS server with Arista VSA dictionary |
| `freeradius-client/` | `ghcr.io/titom73/radtest` | `git.as73.inetsix.net/docker/radtest` | Alpine 3 | RADIUS testing client |
| `ssh-server/` | `ghcr.io/titom73/ssh-server` | `git.as73.inetsix.net/docker/ssh-server` | Alpine | Lightweight SSH jump host |
| `tacacs-server/` | `ghcr.io/titom73/tacacs-plus` | `git.as73.inetsix.net/docker/tacacs-plus` | Ubuntu 20.04 / Alpine 3.14 | TACACS+ server (multi-stage build from source) |
| `receiver-webhook/` | `ghcr.io/titom73/webhook-receiver` | `git.as73.inetsix.net/docker/webhook-receiver` | Python 3.9-slim | Simple webhook receiver for testing |
| `receiver-snmptrap/` | `ghcr.io/titom73/snmptrap-receiver` | `git.as73.inetsix.net/docker/snmptrap-receiver` | Python 3.9-slim | SNMP trap receiver for lab/demo |

## Key Conventions

- **Dual-Hosting:** Repository is mirrored on GitHub (public) and Forgejo at `git.as73.inetsix.net` (private).
- **Dual-Registry:** All images are published to both `ghcr.io/titom73/*` (GitHub) and `git.as73.inetsix.net/docker/*` (Forgejo).
- **Makefile Variables:** All Makefiles support `REGISTRY`, `NAMESPACE`, `IMAGE_BASE_NAME`, `IMAGE_TAG`, and `BUILD_ARGS` for flexible builds.
- **OCI Labels:** All Dockerfiles use standardized `org.opencontainers.image.*` labels with `SOURCE_REPO_URL` ARG for dual-hosting support.
- **Containerlab topologies:** Each image has a `.clab.yml` or `containerlabs.yml` file for testing with ContainerLab.
- **Conventional Commits:** Commit types are `feat|fix|cut|doc|ci|bump|test|refactor|revert|make|chore`. Scope is the image name when applicable (e.g., `feat(tacacs): ...`). Use imperative mood.
- **Multi-arch:** Most images support linux/amd64 and linux/arm64. `multitool` and `ssh-server` support additional platforms (386, arm/v7, ppc64le) via Docker buildx.
- **Alpine preference:** Use Alpine as base image when possible for minimal size.

## Testing

No unit test framework. Testing is done by:
1. Building the image locally (`make build`)
2. Running a container (`make test` where available, or `docker run`)
3. Deploying a ContainerLab topology to validate integration with network devices

## CI/CD

- **GitHub Actions:** Workflows in `.github/workflows/` handle automated builds and pushes to `ghcr.io/titom73/*` on push to `main` branch.
- **Forgejo Actions:** Workflows in `.forgejo/workflows/` handle automated builds and pushes to `git.as73.inetsix.net/docker/*` on push to `main` branch.
- Both CI systems use the same workflow structure, differing only in registry credentials and target URLs.
