# SSL22:LDAPS KESHI
FROM debian:latest
LABEL version="1.0"
LABEL author=" @keshi ASIX-M11"
LABEL subject="Ldap Server - LDAPS"
RUN apt-get update
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get install -y procps iproute2 tree nmap vim nano ldap-utils systemd slapd openssl 
RUN mkdir /opt/docker
COPY * /opt/docker/
RUN chmod +x /opt/docker/startup.sh
WORKDIR /opt/docker
CMD /opt/docker/startup.sh
EXPOSE 389 636
