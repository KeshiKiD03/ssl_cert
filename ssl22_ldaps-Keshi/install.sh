#! /bin/bash
# @keshi ASIX M11 2021-2022
# instal.lacio slapd edt.org
# -------------------------------------
mkdir /etc/ldap/certs

cp /opt/docker/cacert.pem /etc/ldap/certs/. # PER PROVAR-SE A SI MATEIX COM A CLIENT
cp /opt/docker/cacert.pem /etc/ssl/certs/. # Certificat de CA
cp /opt/docker/servercert.ldap.pem /etc/ldap/certs/. # Certificat del servidor
cp /opt/docker/servercertPLUS.pem /etc/ldap/certs/. # Certificat PLUS del servidor
cp /opt/docker/serverkey.ldap.pem  /etc/ldap/certs/. # Key del servidor

rm -rf /etc/ldap/slapd.d/*
rm -rf /var/lib/ldap/*

cp /opt/docker/slapd.conf /etc/ldap/slapd.conf 

slaptest -f /opt/docker/slapd.conf -F /etc/ldap/slapd.d # Provem i ensamblem el servidor LDAP
slaptest -u -f /opt/docker/slapd.conf -F /etc/ldap/slapd.d

slapadd -F /etc/ldap/slapd.d -l /opt/docker/edt.org.ldif
chown -R openldap.openldap /etc/ldap/slapd.d /var/lib/ldap

cp /opt/docker/ldap.conf /etc/ldap/ldap.conf # PER PROBAR-SE A SI MATEIX


########EXTRA ALTERNATE############

#A /etc/ssl/openssl.cnf li hem d'indicar ext.alternate.conf
#Si volguesim tenir sinonims del host (amb CA valid)  hauriem d'haver creat el certificat del ServerLdap incoporant ext.alternate.conf

#openssl x509 -CA cacert.pem -CAkey cakey.pem -req -in serverrequest.ldap.pem -out servercert.pem -CAcreateserial -extfile ext.alternate.conf -days 360

###################################

