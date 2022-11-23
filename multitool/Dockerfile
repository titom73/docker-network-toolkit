FROM alpine:3.13

EXPOSE 80 443 1180 11443

# Arguement for Password
ARG PASSWORD=password123

# Install some tools in the container and generate self-signed SSL certificates.
# Packages are listed in alphabetical order, for ease of readability and ease of maintenance.
RUN     apk update \
    &&  apk add apache2-utils bash bind-tools busybox-extras curl ethtool git \
                iperf3 iproute2 iputils jq lftp mtr mysql-client \
                netcat-openbsd net-tools nginx  tmux screen nmap openssh-client openssl \
                perl-net-telnet postgresql-client procps rsync socat tcpdump \
                tshark wget openssh libteam open-lldp tcptraceroute \
    && apk add --repository=https://dl-cdn.alpinelinux.org/alpine/edge/community/ --no-cache arp-scan \
    && apk add hping3 --update-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing \
    &&  mkdir /certs /docker \
    &&  chmod 700 /certs \
    &&  openssl req \
        -x509 -newkey rsa:2048 -nodes -days 3650 \
        -keyout /certs/server.key -out /certs/server.crt -subj '/CN=localhost'

# Installing the openssh and bash package, removing the apk cache
RUN sed -i s/#PermitRootLogin.*/PermitRootLogin\ yes/ /etc/ssh/sshd_config \
  && echo "root:${PASSWORD}" | chpasswd \
  && rm -rf /var/cache/apk/*

# Defining the Port 22 for service
RUN sed -ie 's/#Port 22/Port 22/g' /etc/ssh/sshd_config
RUN /usr/bin/ssh-keygen -A
RUN ssh-keygen -t rsa -b 4096 -f  /etc/ssh/ssh_host_key
ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

# Configure CA for SSH
RUN echo "TrustedUserCAKeys /etc/ssh/ca.pub" >>/etc/ssh/sshd_config \
    && echo "AuthorizedPrincipalsFile %h/.ssh/authorized_principals" >>/etc/ssh/sshd_config \
    && mkdir ~root/.ssh \
    && echo "mysocket_ssh_signed" > ~root/.ssh/authorized_principals

# Copy a simple index.html to eliminate text (index.html) noise which comes with default nginx image.
# (I created an issue for this purpose here: https://github.com/nginxinc/docker-nginx/issues/234)

COPY index.html /usr/share/nginx/html/

# Copy a custom/simple nginx.conf which contains directives
#   to redirected access_log and error_log to stdout and stderr.
# Note: Don't use '/etc/nginx/conf.d/' directory for nginx virtual hosts anymore.
#   This 'include' will be moved to the root context in Alpine 3.14.

COPY nginx.conf /etc/nginx/nginx.conf

COPY entrypoint.sh /docker/entrypoint.sh

# Note: If you have not included the "bash" package, then it is "mandatory" to add "/bin/sh"
#         in the ENTNRYPOINT instruction.
#       Otherwise you will get strange errors when you try to run the container.
#       Such as:
#       standard_init_linux.go:219: exec user process caused: no such file or directory

# Run the startup script as ENTRYPOINT, which does few things and then starts nginx.
ENTRYPOINT ["/bin/sh", "/docker/entrypoint.sh"]

# Start nginx in foreground:
CMD ["/usr/sbin/nginx", "-g", "daemon off;"]

###################################################################################################

# Build and Push (to dockerhub) instructions:
# -------------------------------------------
# docker build -t local/network-multitool .
# docker tag local/network-multitool titom73/multitool
# docker login
# docker push titom73/multitool


# Pull (from dockerhub):
# ----------------------
# docker pull titom73/multitool


# Usage - on Docker:
# ------------------
# docker run --rm -it titom73/multitool /bin/bash
# OR
# docker run -d  titom73/multitool
# OR
# docker run -p 80:80 -p 443:443 -d  titom73/multitool
# OR
# docker run -e HTTP_PORT=1180 -e HTTPS_PORT=11443 -p 1180:1180 -p 11443:11443 -d  titom73/multitool


# Usage - on Kubernetes:
# ---------------------
# kubectl run multitool --image=titom73/multitool
