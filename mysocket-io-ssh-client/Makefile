
IMAGE_NAME ?= titom73/ssh-mysocket-io
IMAGE_TAG ?= dev
DOCKER_ARGS ?=

.PHONY: help
help: ## Display help message (*: main entry points / []: part of an entry point)
	@grep -E '^[0-9a-zA-Z_-]+\.*[0-9a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: build
build:  ## Build image locally
	docker build -t $(IMAGE_NAME):$(IMAGE_TAG) $(DOCKER_ARGS) .

.PHONY: push
push:  ## Push image to remote registry
	docker push $(IMAGE_NAME):$(IMAGE_TAG)

.PHONY: test
test:  ## Start a container in daemon mode
	docker run -d --rm -P $(IMAGE_NAME):$(IMAGE_TAG)
