FROM almalinux:8 AS base

LABEL org.opencontainers.image.authors="thomas.grimonet@gmail.com"

ENV TAC_PLUS_BIN=/tacacs/sbin/tac_plus
ENV MANPATH=/tacacs/share/man
ENV CONF_FILE=/etc/tac_plus/tac_plus.cfg
ARG COMMIT_ID=69fd5b3aa2abb7bda25aefbdcdeefbecc4a11cc2
ARG VERSION=F4.0.4.28

FROM base AS build
# RUN wget $(echo "https://pkgs.dyn.su/el8/base/x86_64/raven-release.el8.noarch.rpm" | sed "s/el9/el$(rpm -q --queryformat '%{RELEASE}' rpm | grep -oP 'el\K[0-9]+')/g")
ADD https://pkgs.dyn.su/el8/base/x86_64/raven-release-1.0-2.el8.noarch.rpm  raven-release.el8.noarch.rpm
RUN dnf install -y raven-release.el8.noarch.rpm
RUN dnf install -y --repo raven tcp_wrappers-devel tcp_wrappers
RUN dnf install -y make gcc flex bison pam-devel
ADD https://github.com/facebook/tac_plus/archive/$COMMIT_ID.tar.gz /tac_plus.tar.gz
RUN tar -xf /tac_plus.tar.gz && \
    cd tac_plus-$COMMIT_ID/tacacs-$VERSION && \
    ./configure --prefix=/tacacs && \
    make && \
    make install


FROM base
RUN dnf install -y epel-release
RUN dnf install -y tcp_wrappers man
COPY --from=build /tacacs /tacacs
COPY entrypoint.sh /entrypoint.sh
RUN chmod u+x /entrypoint.sh
EXPOSE 49
ENTRYPOINT ["/entrypoint.sh"]