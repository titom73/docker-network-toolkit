FROM alpine:3.13
MAINTAINER Thomas Grimonet <thomas.grimonet@gmail.com>

# Expose SSH port
EXPOSE 22
# Arguement for Password
ARG PASSWORD=password123

# Installing the openssh and bash package, removing the apk cache
RUN apk --update add --no-cache openssh bash tmux screen nmap open-lldp\
  && sed -i s/#PermitRootLogin.*/PermitRootLogin\ yes/ /etc/ssh/sshd_config \
  && echo "root:${PASSWORD}" | chpasswd \
  && rm -rf /var/cache/apk/*

# Defining the Port 22 for service
RUN sed -ie 's/#Port 22/Port 22/g' /etc/ssh/sshd_config
RUN /usr/bin/ssh-keygen -A
RUN ssh-keygen -t rsa -b 4096 -f  /etc/ssh/ssh_host_key
ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

RUN echo "TrustedUserCAKeys /etc/ssh-ca.pub" >>/etc/ssh/sshd_config
RUN echo "AuthorizedPrincipalsFile %h/.ssh/authorized_principals" >>/etc/ssh/sshd_config
RUN mkdir -p /root/.ssh
RUN echo "mysocket_ssh_signed" > /root/.ssh/authorized_principals

USER root
CMD ["/usr/sbin/sshd", "-D"]
