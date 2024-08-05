VERSION?=20240805
SHA256?=f2695a7cc908e03bab8ffb0a84603a0ad103b4532cc84900624899cc1c32e4ab
DOCKER_HUB_NAME?='git.as73.inetsix.net/docker/tacacs_plus'

.PHONY: alpine ubuntu tag push

all: alpine ubuntu tag

alpine:
	docker build -t tac_plus:alpine \
		--build-arg SRC_HASH=$(SHA256) \
		-f Dockerfile.alpine .

ubuntu:
	docker build -t tac_plus:ubuntu \
		--build-arg SRC_HASH=$(SHA256) \
		-f Dockerfile .

tag:
	docker tag tac_plus:ubuntu $(DOCKER_HUB_NAME):latest
	docker tag tac_plus:ubuntu $(DOCKER_HUB_NAME):ubuntu
	docker tag tac_plus:ubuntu $(DOCKER_HUB_NAME):ubuntu-$(VERSION)

	docker tag tac_plus:alpine $(DOCKER_HUB_NAME):alpine
	docker tag tac_plus:alpine $(DOCKER_HUB_NAME):alpine-$(VERSION)

push:
	docker push $(DOCKER_HUB_NAME):latest
	docker push $(DOCKER_HUB_NAME):ubuntu
	docker push $(DOCKER_HUB_NAME):ubuntu-$(VERSION)
	docker push $(DOCKER_HUB_NAME):alpine
	docker push $(DOCKER_HUB_NAME):alpine-$(VERSION)