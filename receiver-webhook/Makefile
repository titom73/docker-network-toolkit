# Registry configuration
REGISTRY ?= ghcr.io
NAMESPACE ?= titom73
IMAGE_BASE_NAME ?= webhook-receiver
IMAGE_TAG ?= dev

# Computed image name
IMAGE_NAME = $(REGISTRY)/$(NAMESPACE)/$(IMAGE_BASE_NAME)

# Build arguments
BUILD_ARGS ?= --build-arg SOURCE_REPO_URL=https://github.com/titom73/docker-network-toolkit
DOCKER_ARGS ?=

.PHONY: help
help: ## Display help message
	@echo "Registry: $(REGISTRY)/$(NAMESPACE)"
	@echo "Image: $(IMAGE_NAME):$(IMAGE_TAG)"
	@echo ""
	@grep -E '^[0-9a-zA-Z_-]+\.*[0-9a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: build
build:  ## Build image locally
	docker build -t $(IMAGE_NAME):$(IMAGE_TAG) $(BUILD_ARGS) $(DOCKER_ARGS) .

.PHONY: push
push:  ## Push image to configured registry
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

.PHONY: test
test:  ## Start a container in daemon mode for testing
	docker run -d --rm -p 8282:80 --name webhook-test $(IMAGE_NAME):$(IMAGE_TAG)

.PHONY: stop
stop:  ## Stop test container
	docker stop webhook-test || true

.PHONY: logs
logs:  ## View container logs
	docker logs -f webhook-test

