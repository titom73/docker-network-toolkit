
IMAGE_NAME ?= titom73/network-multitool
IMAGE_TAG ?= dev
DOCKER_FILE ?= Dockerfile

.PHONY: build
build:  ## Build image locally
	docker build -t $(IMAGE_NAME):$(IMAGE_TAG) -f $(DOCKER_FILE) .

.PHONY: push
push:  ## Push image to remote registry
	docker push $(IMAGE_NAME):$(IMAGE_TAG)