FROM alpine:3

WORKDIR /projects

RUN apk update && apk upgrade && \
    apk add --update freeradius-radclient openssl-dev && \
    rm /var/cache/apk/*

ENTRYPOINT [ "/usr/bin/radtest" ]

CMD ["--version"]