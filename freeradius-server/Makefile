
IMAGE_NAME ?= titom73/radius
IMAGE_TAG ?= dev

.PHONY: build
build:  ## Build image locally
	docker build -t $(IMAGE_NAME):$(IMAGE_TAG) .

.PHONY: push
push:  ## Push image to remote registry
	docker push $(IMAGE_NAME):$(IMAGE_TAG)