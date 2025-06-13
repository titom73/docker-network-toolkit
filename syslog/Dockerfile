ARG IMAGE_BASE=balabit/syslog-ng
ARG IMAGE_TAG=latest
ARG BUILDPLATFORM=linux/amd64

FROM --platform=$BUILDPLATFORM ${IMAGE_BASE}:${IMAGE_TAG}

EXPOSE 514/udp
EXPOSE 601/tcp
EXPOSE 6514/tcp

# Copy the syslog-ng configuration file
COPY syslog-ng.conf /etc/syslog-ng/syslog-ng.conf
RUN mkdir -p /var/log

# CMD [ "tail", "-f", "/var/log/messages" ]