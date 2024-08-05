
IMAGE_NAME ?= git.as73.inetsix.net/docker/freeradius
IMAGE_TAG ?= latest

.PHONY: build
build:  ## Build image locally
	docker build -t $(IMAGE_NAME):$(IMAGE_TAG) .

.PHONY: push
push:  ## Push image to remote registry
	docker push $(IMAGE_NAME):$(IMAGE_TAG)
