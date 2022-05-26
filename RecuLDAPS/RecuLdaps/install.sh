#! /bin/bash
# @keshi ASIX M11 2021-2022
# instal.lacio slapd edt.org
# -------------------------------------
mkdir /etc/ldap/certs

cp /opt/docker/ca_keshi_cert.pem /etc/ldap/certs/. # PER PROVAR-SE A SI MATEIX COM A CLIENT
cp /opt/docker/ca_keshi_cert.pem /etc/ssl/certs/. # Certificat de CA
cp /opt/docker/servercert.ldap.pem /etc/ldap/certs/. # Certificat del servidor

cp /opt/docker/serverkey.ldap.pem  /etc/ldap/certs/. # Key del servidor


rm -rf /etc/ldap/slapd.d/*
rm -rf /var/lib/ldap/*

cp /opt/docker/slapd.conf /etc/ldap/slapd.conf

slaptest -f /opt/docker/slapd.conf -F /etc/ldap/slapd.d # Provem i ensamblem el servidor LDAP
slaptest -u -f /opt/docker/slapd.conf -F /etc/ldap/slapd.d

slapadd -F /etc/ldap/slapd.d -l /opt/docker/edt.org.ldif # Populate de LDAP
chown -R openldap.openldap /etc/ldap/slapd.d /var/lib/ldap

cp /opt/docker/ldap.conf /etc/ldap/ldap.conf # Necesari per probar-se a si mateix

# ~~~~ Subject Alternative Name ~~~~

# Si volem tenir sinónims de host (amb C) hauriem d'haver creat el  certificat del ServerLdap incorporant extserver.cnf

# Generar Key y Req

# openssl req -newkey rsa:2048 -nodes -sha256 -keyout serverkey_ldap.pem -out serverrequest_ldap.pem -config extserver.cnf.

# Firmar y generar Cert

# openssl x509 -CAkey cakey.pem -CA ca-NOMBRE-cert.pem -req -in serverrequest_ldap.pem -days 3650 -CAcreateserial -out servercert_ldap.pem -extensions 'aaron_req' -extfile extserver.cnf

# o 

#openssl x509 -CA ca_leomessi_cert.pem -CAkey cakey.pem -req -in serverrequest_ldap.pem -out servercertEXT.pem -CAcreateserial -extfile ext.alternate.conf -days 360

# ~~~~ ~~~~ ~~~~ ~~~~
