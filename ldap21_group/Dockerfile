# ldap21:Group
FROM debian:latest
LABEL author="@keshi ASIX M11-ISO"
LABEL subject="Ldap Server - LDAPS"
RUN apt-get update
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get -y install procps iproute2 tree nmap vim ldap-utils slapd openssl
RUN mkdir /opt/docker
COPY * /opt/docker/
RUN chmod +x /opt/docker/startup.sh
WORKDIR /opt/docker
CMD /opt/docker/startup.sh
EXPOSE 389 636
