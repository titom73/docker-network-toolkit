ARG SOURCE_REPO_URL=https://github.com/titom73/docker-network-toolkit

FROM python:3.9-slim

EXPOSE 162/udp

WORKDIR /local
COPY . /local

RUN pip install --no-cache-dir .

# OCI Labels
LABEL   "org.opencontainers.image.title"="SNMP Trap Receiver" \
        "org.opencontainers.artifact.description"="Simple SNMP trap receiver for testing" \
        "org.opencontainers.image.description"="A simple SNMP trap receiver for demo and lab purposes" \
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
CMD ["bin/snmptrap-receiver"]

