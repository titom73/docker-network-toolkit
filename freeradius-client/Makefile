# Container image configuration
REGISTRY ?= git.as73.inetsix.net
NAMESPACE ?= docker
IMAGE_BASE_NAME ?= radtest
IMAGE_TAG ?= dev
IMAGE_NAME = $(REGISTRY)/$(NAMESPACE)/$(IMAGE_BASE_NAME)
BUILD_ARGS ?= --build-arg SOURCE_REPO_URL=https://git.as73.inetsix.net/docker/docker-network-toolkit
DOCKER_FILE ?= Dockerfile
PLATFORM ?= $(shell uname -m | sed 's/x86_64/amd64/' | sed 's/aarch64/arm64/')

.PHONY: build
build:  ## Build and load image locally for local platform
	docker buildx build --platform linux/$(PLATFORM) $(BUILD_ARGS) --load -t $(IMAGE_NAME):$(IMAGE_TAG) -f $(DOCKER_FILE) .

.PHONY: buildx
buildx:  ## Build and push image for multiple platforms
	docker buildx build --platform linux/amd64,linux/arm64 $(BUILD_ARGS) -t $(IMAGE_NAME):$(IMAGE_TAG) -f $(DOCKER_FILE) . --push

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
