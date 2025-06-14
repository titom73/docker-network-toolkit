
IMAGE_NAME ?= titom73/ssh-server
IMAGE_TAG ?= dev
DOCKER_ARGS ?=
DOCKER_FILE ?= Dockerfile
PLATFORM ?= $(shell uname -m | sed 's/x86_64/amd64/' | sed 's/aarch64/arm64/')

.PHONY: build
build:  ## Build and load image locally for local platform
	docker buildx build --platform linux/$(PLATFORM) --load -t $(IMAGE_NAME):$(IMAGE_TAG) -f $(DOCKER_FILE) .

.PHONY: buildx
buildx:  ## Build and push image for multiple platforms
	docker buildx build --platform linux/amd64,linux/arm64 -t $(IMAGE_NAME):$(IMAGE_TAG) -f $(DOCKER_FILE) . --push

.PHONY: push
push:  ## Push image to remote registry
	docker push $(IMAGE_NAME):$(IMAGE_TAG)

.PHONY: test
test:  ## Start a container in daemon mode
	docker run -d --rm -P $(IMAGE_NAME):$(IMAGE_TAG)
