# Unified Makefile for all Docker lab images
# This file lets you drive every sub-project Makefile from the repository root.
#
# Conventions
# - Each subfolder contains its own Makefile (already present in this repo).
# - Common targets across projects: build, buildx, push
# - Some projects expose extra targets like test, run, sh, log
#
# How to use
# - List projects:            make projects
# - Build one project:        make build PROJECT=ssh-server
# - Build all projects:       make build-all
# - Multi-arch build+push:    make buildx PROJECT=multitool
# - Push all (only where available): make push-all
# - Shortcut per-project:     make ssh-server.build  | make freeradius-server.run | make ssh-server.test
#
# Variables you can forward to sub-makes (optional):
#   REGISTRY_PREFIX, IMAGE_NAME, IMAGE_TAG, DOCKER_FILE, PLATFORM, SHA256, VERSION, DOCKER_ARGS, RADIUS_CONTAINER
#
# Container naming:
#   REGISTRY_PREFIX: Default registry/namespace (default: git.as73.inetsix.net/docker)
#   IMAGE_NAME: Full image name override (default: ${REGISTRY_PREFIX}/${PROJECT})
#
# Examples:
#   make build PROJECT=multitool                                    # Uses git.as73.inetsix.net/docker/multitool
#   make build PROJECT=multitool REGISTRY_PREFIX=myregistry.com     # Uses myregistry.com/multitool
#   make build PROJECT=multitool IMAGE_NAME=custom/image:tag        # Uses custom/image:tag

# Nice output and consistent ordering
MAKEFLAGS += --no-print-directory
# Use bash for robust piping/errexit behavior across platforms
SHELL := /bin/bash
.SHELLFLAGS := -eu -o pipefail -c

# Container registry configuration
REGISTRY_PREFIX ?= git.as73.inetsix.net/docker

# Discover all project folders that contain a Makefile (one level deep)
PROJECTS := $(sort $(patsubst %/,%,$(dir $(wildcard */Makefile))))

# Detect which projects have a given target (e.g., push)
# Note: macOS/BSD grep supports -E; use POSIX character classes for safety
PUSH_PROJECTS := $(strip $(shell for d in $(PROJECTS); do \
	if [ -f $$d/Makefile ] && grep -Eq '^[[:space:]]*push:' $$d/Makefile; then echo $$d; fi; \
	done))

# Variables to forward to sub-make calls if set
FORWARD_VARS ?= REGISTRY_PREFIX IMAGE_TAG IMAGE_NAME DOCKER_FILE PLATFORM SHA256 VERSION DOCKER_ARGS RADIUS_CONTAINER
MAKE_ARGS     := $(foreach v,$(FORWARD_VARS),$(if $($(v)),$(v)=$($(v)),))

# ------------- Utilities -------------

.PHONY: help
help: ## Show this help
	@awk 'BEGIN {FS = ":.*##"} /^[a-zA-Z0-9_.-]+:.*##/ {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)
	@echo "Projects:"; echo "  $(PROJECTS)" | fold -s -w 100 | sed 's/^/  /'
	@echo "Shortcuts:"; echo "  <project>.build  <project>.buildx  <project>.push  <project>.test  <project>.run  <project>.sh  <project>.log"
	@echo "Container naming:"
	@echo "  * REGISTRY_PREFIX=$(REGISTRY_PREFIX)"
	@echo "  * Override with: make build PROJECT=<name> REGISTRY_PREFIX=<your-registry>"
	@echo "  * Full override:  make build PROJECT=<name> IMAGE_NAME=<full-image-name>"

.PHONY: projects
projects: ## List all detected projects
	@echo $(PROJECTS)

# Ensure PROJECT is set and valid
# Usage in targets: $(call require_project)
require_project = \
	$(if $(PROJECT),,$(error Please provide PROJECT=<one of: $(PROJECTS)>)) \
	$(if $(filter $(PROJECT),$(PROJECTS)),,$(error Unknown PROJECT='$(PROJECT)'. Choose from: $(PROJECTS)))

# ------------- Aggregated targets -------------

.PHONY: build
build: ## Build and load image locally for the selected PROJECT (PROJECT=<name>)
	$(call require_project)
	@$(MAKE) -C $(PROJECT) build $(MAKE_ARGS)

.PHONY: buildx
buildx: ## Build and push multi-arch image for the selected PROJECT (PROJECT=<name>)
	$(call require_project)
	@$(MAKE) -C $(PROJECT) buildx $(MAKE_ARGS)

.PHONY: push
push: ## Push image for the selected PROJECT (PROJECT=<name>)
	$(call require_project)
	@$(MAKE) -C $(PROJECT) push $(MAKE_ARGS)

.PHONY: build-all
build-all: ## Build and load images for all projects
	@set -e; for d in $(PROJECTS); do \
		echo "==> Building $$d"; \
		$(MAKE) -C $$d build $(MAKE_ARGS); \
	done

.PHONY: buildx-all
buildx-all: ## Build and push multi-arch images for all projects
	@set -e; for d in $(PROJECTS); do \
		echo "==> Buildx $$d"; \
		$(MAKE) -C $$d buildx $(MAKE_ARGS); \
	done

.PHONY: push-all
push-all: ## Push images for all projects that provide a 'push' target
	@if [ -z "$(PUSH_PROJECTS)" ]; then \
		echo "No projects expose a 'push' target."; \
	else \
		set -e; for d in $(PUSH_PROJECTS); do \
			echo "==> Pushing $$d"; \
			$(MAKE) -C $$d push $(MAKE_ARGS); \
		done; \
	fi

# ------------- Per-project shortcuts -------------
# Call like: make ssh-server.build  |  make freeradius-server.run  |  make ssh-server.test

.PHONY: %.build
%.build: ## Build a specific project using '<project>.build'
	@$(MAKE) -C $* build $(MAKE_ARGS)

.PHONY: %.buildx
%.buildx: ## Buildx a specific project using '<project>.buildx'
	@$(MAKE) -C $* buildx $(MAKE_ARGS)

.PHONY: %.push
%.push: ## Push a specific project using '<project>.push'
	@$(MAKE) -C $* push $(MAKE_ARGS)

.PHONY: %.test
%.test: ## Run project test target using '<project>.test' (if available)
	@$(MAKE) -C $* test $(MAKE_ARGS)

.PHONY: %.run
%.run: ## Run project using '<project>.run' (if available)
	@$(MAKE) -C $* run $(MAKE_ARGS)

.PHONY: %.sh
%.sh: ## Exec into running container using '<project>.sh' (if available)
	@$(MAKE) -C $* sh $(MAKE_ARGS)

.PHONY: %.log
%.log: ## Tail logs using '<project>.log' (if available)
	@$(MAKE) -C $* log $(MAKE_ARGS)

# Default target
.DEFAULT_GOAL := help
