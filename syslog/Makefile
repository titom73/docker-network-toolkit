
IMAGE_NAME ?= git.as73.inetsix.net/docker/syslog
IMAGE_TAG ?= dev
DOCKER_FILE ?= Dockerfile

.PHONY: build
build:  ## Build image locally
	docker build -t $(IMAGE_NAME):$(IMAGE_TAG) -f $(DOCKER_FILE) .

.PHONY: buildx
buildx:  ## Build image using buildx
	docker buildx build --platform linux/amd64,linux/arm64 -t $(IMAGE_NAME):$(IMAGE_TAG) -f $(DOCKER_FILE) .

.PHONY: push
push:  ## Push image to remote registry
	docker push $(IMAGE_NAME):$(IMAGE_TAG)