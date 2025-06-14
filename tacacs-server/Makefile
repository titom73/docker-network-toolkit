VERSION?=20240805
SHA256?=f2695a7cc908e03bab8ffb0a84603a0ad103b4532cc84900624899cc1c32e4ab
IMAGE_NAME ?= git.as73.inetsix.net/docker/tacplus
IMAGE_TAG ?= dev
DOCKER_FILE ?= Dockerfile
PLATFORM ?= $(shell uname -m | sed 's/x86_64/amd64/' | sed 's/aarch64/arm64/')

.PHONY: build
build:  ## Build and load image locally for local platform
	docker buildx build --platform linux/$(PLATFORM) --load \
	--build-arg SRC_HASH=$(SHA256) \
	-t $(IMAGE_NAME):$(IMAGE_TAG) -f $(DOCKER_FILE) .

.PHONY: buildx
buildx:  ## Build and push image for multiple platforms
	docker buildx build --platform linux/amd64,linux/arm64 \
	--build-arg SRC_HASH=$(SHA256) \
	-t $(IMAGE_NAME):$(IMAGE_TAG) -f $(DOCKER_FILE) . --push

.PHONY: push
push:  ## Push image to remote registry
	docker push $(IMAGE_NAME):$(IMAGE_TAG)