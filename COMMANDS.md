# Repository-wide Makefile commands

This document explains how to use the unified Makefile at the root of the repository to manage all Docker lab images in the subprojects.

The root Makefile discovers subfolders that contain a `Makefile` (one level deep) and lets you run common targets for a single project or for all projects at once.

## Prerequisites

- Docker with Buildx enabled.
- GNU Make (the Makefile uses pattern rules).
- Bash is used as the shell (`/bin/bash`) to support `pipefail`.

## Projects discovery

List all detected projects:

```sh
make projects
```

The command prints all subdirectories that contain a `Makefile`, for example:

```text
freeradius-client freeradius-server multitool ssh-server syslog tacacs-server
```

## Forwarded variables

You can forward these variables to sub-makes:

- `REGISTRY_PREFIX`, `IMAGE_TAG`, `IMAGE_NAME`, `DOCKER_FILE`, `PLATFORM`
- `SHA256`, `VERSION`, `DOCKER_ARGS`, `RADIUS_CONTAINER`

Example:

```sh
make build PROJECT=tacacs-server IMAGE_TAG=latest REGISTRY_PREFIX=myregistry.com
```

## Container naming configuration

The build system supports flexible container naming through configurable variables:

### Available variables

#### REGISTRY_PREFIX
- **Default**: `git.as73.inetsix.net/docker`
- **Description**: Registry/namespace prefix for all containers
- **Usage**: `make build PROJECT=multitool REGISTRY_PREFIX=myregistry.com`

#### IMAGE_NAME
- **Default**: `${REGISTRY_PREFIX}/${PROJECT_NAME}`
- **Description**: Full image name (complete override)
- **Usage**: `make build PROJECT=multitool IMAGE_NAME=custom/image`

#### IMAGE_TAG
- **Default**: `dev`
- **Description**: Image tag
- **Usage**: `make build PROJECT=multitool IMAGE_TAG=v1.0.0`

### Usage examples

#### Default configuration
```sh
make build PROJECT=multitool
# Result: git.as73.inetsix.net/docker/multitool:dev
```

#### Registry change
```sh
make build PROJECT=multitool REGISTRY_PREFIX=harbor.mycompany.com/network-tools
# Result: harbor.mycompany.com/network-tools/multitool:dev
```

#### Complete override
```sh
make build PROJECT=multitool IMAGE_NAME=mycustomregistry/tools/multitool IMAGE_TAG=latest
# Result: mycustomregistry/tools/multitool:latest
```

#### Build all projects with custom registry
```sh
make build-all REGISTRY_PREFIX=myregistry.io/network-lab
# Builds all projects with myregistry.io/network-lab prefix
```

## Core targets (root level)

- `help` — Show available root-level targets, shortcuts, and container naming configuration.
- `projects` — List all detected projects.
- `build` — Build a single project locally. Requires `PROJECT=<name>`.
- `buildx` — Multi-arch build and push for a single project. Requires `PROJECT=<name>`.
- `push` — Push a single project. Requires `PROJECT=<name>`.
- `build-all` — Build all projects locally.
- `buildx-all` — Multi-arch build and push for all projects.
- `push-all` — Push all projects that expose a `push` target.

## Per-project shortcuts

For convenience, you can call a project's targets directly from the root using:

- `<project>.build`
- `<project>.buildx`
- `<project>.push`
- `<project>.test` (if that project defines `test`)
- `<project>.run` (if that project defines `run`)
- `<project>.sh` (if that project defines `sh`)
- `<project>.log` (if that project defines `log`)

Examples:

```sh
make ssh-server.build
make freeradius-server.run
make freeradius-server.sh
make syslog.push
```

## Single-project examples

- Build locally:

  ```sh
  make build PROJECT=ssh-server
  ```

- Multi-arch build and push:

  ```sh
  make buildx PROJECT=multitool
  ```

- Push image:

  ```sh
  make push PROJECT=syslog
  ```

## All-projects examples

- Build all locally:

  ```sh
  make build-all
  ```

- Multi-arch build and push all:

  ```sh
  make buildx-all
  ```

- Push all (only where `push` is defined):

  ```sh
  make push-all
  ```

## Notes

- If you invoke a per-project shortcut for a target that the project does not define (e.g., `test`), Make will fail with the usual "No rule to make target" message.
- The root Makefile forwards supported variables only when you set them; otherwise, each project uses its own defaults.

## Migration from legacy configuration

Project Makefiles should be updated to use the new flexible naming structure:

**Legacy format:**
```makefile
IMAGE_NAME ?= git.as73.inetsix.net/docker/multitool
```

**New format:**
```makefile
REGISTRY_PREFIX ?= git.as73.inetsix.net/docker
PROJECT_NAME ?= multitool
IMAGE_NAME ?= $(REGISTRY_PREFIX)/$(PROJECT_NAME)
```

## Environment configuration

You can create a `.env` file (copy from `.env.example`) to set default values:

```bash
# Default registry for all containers
REGISTRY_PREFIX=git.as73.inetsix.net/docker

# Default tag
IMAGE_TAG=dev

# Alternative registry examples:
# REGISTRY_PREFIX=harbor.mycompany.com/network-tools
# REGISTRY_PREFIX=docker.io/myusername
# REGISTRY_PREFIX=ghcr.io/myorg
```

This structure provides better flexibility while maintaining compatibility with existing configurations.
