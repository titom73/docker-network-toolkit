FROM freeradius/freeradius-server:latest

LABEL   "org.opencontainers.image.title"="Freeradius" \
    "org.opencontainers.artifact.description"="A simple Freeradius docker image." \
    "org.opencontainers.image.description"="A simple Freeradius docker image with Arista dictionary installed." \
    "org.opencontainers.image.source"="https://github.com/titom73/docker-network-toolkit" \
    "org.opencontainers.image.url"="https://github.com/titom73/docker-network-toolkit" \
    "org.opencontainers.image.documentation"="https://github.com/titom73/docker-network-toolkit" \
    "org.opencontainers.image.licenses"="Apache-2.0" \
    "org.opencontainers.image.vendor"="TiTom73" \
    "org.opencontainers.image.authors"="Thomas Grimonet" \
    "org.opencontainers.image.base.name"="freeradius/freeradius-server" \
    "org.opencontainers.image.revision"="dev" \
    "org.opencontainers.image.version"="latest"

COPY raddb/ /etc/raddb/
COPY dictionaries/dictionary.arista /usr/share/freeradius/
RUN echo '$INCLUDE dictionary.arista' >> /usr/share/freeradius/dictionary

EXPOSE 1812 1813

CMD ["freeradius", "-X"]