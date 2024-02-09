FROM alpine:3

LABEL   "org.opencontainers.image.title"="Freeradius Client" \
    "org.opencontainers.artifact.description"="A simple Freeradius Client docker image." \
    "org.opencontainers.image.description"="A simple Freeradius Client docker image for lab testing." \
    "org.opencontainers.image.source"="https://github.com/titom73/docker-network-toolkit" \
    "org.opencontainers.image.url"="https://github.com/titom73/docker-network-toolkit" \
    "org.opencontainers.image.documentation"="https://github.com/titom73/docker-network-toolkit" \
    "org.opencontainers.image.licenses"="Apache-2.0" \
    "org.opencontainers.image.vendor"="TiTom73" \
    "org.opencontainers.image.authors"="Thomas Grimonet" \
    "org.opencontainers.image.base.name"="freeradius/freeradius-server" \
    "org.opencontainers.image.revision"="dev" \
    "org.opencontainers.image.version"="latest"

WORKDIR /projects

RUN apk update && apk upgrade && \
    apk add --update freeradius-radclient openssl-dev && \
    rm /var/cache/apk/*

ENTRYPOINT [ "/usr/bin/radtest" ]

CMD ["--version"]