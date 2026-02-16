ARG SOURCE_REPO_URL=https://github.com/titom73/docker-network-toolkit
ARG ALPINE_VERSION=${ALPINE_VERSION:-latest}

FROM alpine:${ALPINE_VERSION}

MAINTAINER Thomas Grimonet <thomas.grimonet@gmail.com>

ENV ROOT_PASSWORD=password123
ENV KEYPAIR_LOGIN=false

ADD entrypoint.sh /
RUN apk update && apk upgrade && apk add openssh \
    && chmod +x /entrypoint.sh \
    && mkdir -p /root/.ssh \
    && rm -rf /var/cache/apk/* /tmp/*

# OCI Labels
LABEL   "org.opencontainers.image.title"="SSH Server" \
        "org.opencontainers.artifact.description"="Lightweight SSH jump host" \
        "org.opencontainers.image.description"="Lightweight SSH jump host for mysocket.io and containerlab" \
        "org.opencontainers.image.source"="${SOURCE_REPO_URL}" \
        "org.opencontainers.image.url"="${SOURCE_REPO_URL}" \
        "org.opencontainers.image.documentation"="${SOURCE_REPO_URL}" \
        "org.opencontainers.image.licenses"="Apache-2.0" \
        "org.opencontainers.image.vendor"="TiTom73" \
        "org.opencontainers.image.authors"="Thomas Grimonet" \
        "org.opencontainers.image.base.name"="alpine:${ALPINE_VERSION}" \
        "org.opencontainers.image.revision"="dev" \
        "org.opencontainers.image.version"="latest"

EXPOSE      22
VOLUME      ["/etc/ssh"]
ENTRYPOINT  ["/entrypoint.sh"]
