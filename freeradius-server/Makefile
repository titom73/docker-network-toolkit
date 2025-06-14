
IMAGE_NAME ?= git.as73.inetsix.net/docker/freeradius
IMAGE_TAG ?= dev
DOCKER_FILE ?= Dockerfile
PLATFORM ?= $(shell uname -m | sed 's/x86_64/amd64/' | sed 's/aarch64/arm64/')

.PHONY: build
build:  ## Build and load image locally for local platform
	docker buildx build --platform linux/$(PLATFORM) --load -t $(IMAGE_NAME):$(IMAGE_TAG) -f $(DOCKER_FILE) .

.PHONY: buildx
buildx:  ## Build and push image for multiple platforms
	docker buildx build --platform linux/amd64,linux/arm64 -t $(IMAGE_NAME):$(IMAGE_TAG) -f $(DOCKER_FILE) . --push

.PHONY: sh
sh:
	docker container exec -it ${RADIUS_CONTAINER} sh

.PHONY: log
log:
	docker container logs ${RADIUS_CONTAINER} --follow

.PHONY: run
run:
	docker run -d -t --name ${RADIUS_CONTAINER} -p 1812:1812/udp -p 1813:1813/udp $(IMAGE_NAME):$(IMAGE_TAG)
	docker ps