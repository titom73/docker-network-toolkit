
IMAGE_NAME ?= git.as73.inetsix.net/docker/freeradius
IMAGE_TAG ?= latest
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