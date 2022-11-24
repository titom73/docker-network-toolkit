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

EXPOSE      22
VOLUME      ["/etc/ssh"]
ENTRYPOINT  ["/entrypoint.sh"]
