ARG SOURCE_REPO_URL=https://github.com/titom73/docker-network-toolkit

FROM python:3.9-slim

EXPOSE 80

WORKDIR /local
COPY . /local

RUN pip install .

# OCI Labels
LABEL   "org.opencontainers.image.title"="Webhook Receiver" \
        "org.opencontainers.artifact.description"="Simple webhook receiver for testing" \
        "org.opencontainers.image.description"="A simple webhook receiver for demo and lab purposes" \
        "org.opencontainers.image.source"="${SOURCE_REPO_URL}" \
        "org.opencontainers.image.url"="${SOURCE_REPO_URL}" \
        "org.opencontainers.image.documentation"="${SOURCE_REPO_URL}" \
        "org.opencontainers.image.licenses"="Apache-2.0" \
        "org.opencontainers.image.vendor"="TiTom73" \
        "org.opencontainers.image.authors"="Thomas Grimonet" \
        "org.opencontainers.image.base.name"="python:3.9-slim" \
        "org.opencontainers.image.revision"="dev" \
        "org.opencontainers.image.version"="latest"

ENTRYPOINT ["python", "-u"]
CMD [ "bin/webhook-receiver" ]
