ARG SOURCE_REPO_URL=https://github.com/titom73/docker-network-toolkit
ARG IMAGE_BASE=freeradius/freeradius-server
ARG IMAGE_TAG=latest-alpine
ARG BUILDPLATFORM=linux/amd64

FROM --platform=$BUILDPLATFORM ${IMAGE_BASE}:${IMAGE_TAG}

LABEL   "org.opencontainers.image.title"="Freeradius" \
        "org.opencontainers.artifact.description"="A simple Freeradius docker image." \
        "org.opencontainers.image.description"="A simple Freeradius docker image with Arista dictionary installed." \
        "org.opencontainers.image.source"="${SOURCE_REPO_URL}" \
        "org.opencontainers.image.url"="${SOURCE_REPO_URL}" \
        "org.opencontainers.image.documentation"="${SOURCE_REPO_URL}" \
        "org.opencontainers.image.licenses"="Apache-2.0" \
        "org.opencontainers.image.vendor"="TiTom73" \
        "org.opencontainers.image.authors"="Thomas Grimonet" \
        "org.opencontainers.image.base.name"="freeradius/freeradius-server:${IMAGE_TAG}" \
        "org.opencontainers.image.revision"="dev" \
        "org.opencontainers.image.version"="latest"

RUN apk add freeradius-utils

COPY raddb/ /etc/raddb/

# COPY dictionaries/dictionary.arista /usr/share/freeradius/dictionary.arista
# RUN echo "\$INCLUDE dictionary.arista" >> /usr/share/freeradius/dictionary

COPY dictionaries/dictionary.arista /opt/share/freeradius/dictionary.arista
RUN echo "\$INCLUDE dictionary.arista" >> /opt/share/freeradius/dictionary

EXPOSE 1812 1813

CMD ["freeradius", "-X"]
