# TACACS+ version configuration
VERSION ?= 20240805
SHA256 ?= f2695a7cc908e03bab8ffb0a84603a0ad103b4532cc84900624899cc1c32e4ab

# Container image configuration
REGISTRY ?= git.as73.inetsix.net
NAMESPACE ?= docker
IMAGE_BASE_NAME ?= tacacs-plus
IMAGE_TAG ?= dev
IMAGE_NAME = $(REGISTRY)/$(NAMESPACE)/$(IMAGE_BASE_NAME)
BUILD_ARGS ?= --build-arg SOURCE_REPO_URL=https://git.as73.inetsix.net/docker/docker-network-toolkit --build-arg SRC_HASH=$(SHA256)
DOCKER_FILE ?= Dockerfile
PLATFORM ?= $(shell uname -m | sed 's/x86_64/amd64/' | sed 's/aarch64/arm64/')

.PHONY: build
build: ubuntu  ## Build Ubuntu variant (default)

.PHONY: ubuntu
ubuntu:  ## Build Ubuntu variant
	docker buildx build --platform linux/$(PLATFORM) $(BUILD_ARGS) --load -t $(IMAGE_NAME):ubuntu -t $(IMAGE_NAME):$(IMAGE_TAG) -f Dockerfile .

.PHONY: alpine
alpine:  ## Build Alpine variant
	docker buildx build --platform linux/$(PLATFORM) $(BUILD_ARGS) --load -t $(IMAGE_NAME):alpine -f Dockerfile.alpine .

.PHONY: all
all: ubuntu alpine  ## Build both Ubuntu and Alpine variants
	docker tag $(IMAGE_NAME):ubuntu $(IMAGE_NAME):latest

.PHONY: buildx
buildx:  ## Build and push Ubuntu image for multiple platforms
	docker buildx build --platform linux/amd64,linux/arm64 $(BUILD_ARGS) -t $(IMAGE_NAME):ubuntu -t $(IMAGE_NAME):$(IMAGE_TAG) -f Dockerfile . --push

.PHONY: buildx-alpine
buildx-alpine:  ## Build and push Alpine image for multiple platforms
	docker buildx build --platform linux/amd64,linux/arm64 $(BUILD_ARGS) -t $(IMAGE_NAME):alpine -f Dockerfile.alpine . --push

.PHONY: push
push:  ## Push image to remote registry
	docker push $(IMAGE_NAME):$(IMAGE_TAG)

.PHONY: push-github
push-github:  ## Push to GitHub Container Registry
	@$(MAKE) push REGISTRY=ghcr.io NAMESPACE=titom73

.PHONY: push-forgejo
push-forgejo:  ## Push to Forgejo Container Registry
	@$(MAKE) push REGISTRY=git.as73.inetsix.net NAMESPACE=docker

.PHONY: push-all
push-all: push-github push-forgejo  ## Push to all registries

.PHONY: tag-all
tag-all:  ## Tag image for all registries
	docker tag $(IMAGE_NAME):$(IMAGE_TAG) ghcr.io/titom73/$(IMAGE_BASE_NAME):$(IMAGE_TAG)
	docker tag $(IMAGE_NAME):$(IMAGE_TAG) git.as73.inetsix.net/docker/$(IMAGE_BASE_NAME):$(IMAGE_TAG)