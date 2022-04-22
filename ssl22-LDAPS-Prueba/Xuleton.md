# LDAPS
## @isx36579183 ASIX M11-SAD Curs 2021-2022

# Objetivos

1. Conectividad de LDAP con __Certificados TLS/SSL__. 

    --> `A partir de ldap21:group se generará ssl22:ldaps que tendrá certificados propios para el uso de TLS/SSL .`

2. Verificación de la creación de una __Entidad de Certificación__ nueva __"LeoMessi"__ 

    --> `Se creará la Entidad de Certificación a partir de Par de Claves Pub/Priv en el Servidor y generar Certificados de la misma, posteriormente su propagación`.

3. Verificación de comandos de __LDAP 389 y LDAPS 636 y STARTLS -Z / -ZZ__.

# Requisitos

* ldap21:group --> Docker


* openssl CA = "Inventat"

    * Par de claves Pub/Priv para la CA --> ``cakey.pem``

    * CA inventado nuevo a partir de la KEY `cakey.pem` --> ``ca-NOMBRE-cert.pem ``
    * __Subject Alternative Name__ `ldaps://mysecureldapserver.org` a partir de una EXTENSIÓN `extserver.cnf`.

    * Generar `Key Server (serverkey_ldap.pem)` y `Request Server (serverrequest_ldap.pem)` a partir de `extserver.cnf`.

    * Par de claves Pub/Priv para el Servidor LDAP edt.org (_Passwordless_) --> ``serverkey_ldap.pem` 

    * Request de certificado para el Servidor LDAP edt.org a partir de Certificado de la CA (``ca-NOMBRE-cert.pem ``) (_Passwordless_) --> ```serverrequest_ldap.pem``

    * Certificado del Servidor de Ldap edt.org a partir del Request del Certificado (__Lo tiene que firmar__) --> ```servercert_ldap.pem``



# Chuletón Step by Step

1. Generar `PAR de CLAVES` de CA "Inventado" CA:True.

> openssl genrsa -out cakey.pem 1024

* Verificar

2. Generar `REQUEST Autofirmado` CA "Inventado" en formato PEM.

> openssl req -new -x509 -nodes -sha1 -days 365 -key cakey.pem -out ca-NOMBRE-cert.pem 

* Verificar

3. Modificar el `extserver.cnf`.

```
[ aaron_req ]

# Extensions to add to a certificate request
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = @alt_names

[ alt_names ]
DNS.0 = ldap.edt.org
DNS.1 = mysecureldapserver.org
DNS.2 = ldap
IP.1 = [IPDocker]
IP.2 = 127.0.0.1
```

4. Generar una `Key Server` y `Request Server` a partir de una configuración especial (__extserver.cnf__) para LDAP; CA:False.

> openssl req -newkey rsa:2048 -nodes -sha256 -keyout serverkey_ldap.pem -out serverrequest_ldap.pem -config extserver.cnf.

* **-newkey** la clave privada a fabricar sea del tipo RSA:2048

* **-keyout** creará una clave privada con la fabricación del CERTIFICADO, sin password

* **-days** --> Caducidad.

* **Pide passphrase** porque no ha puest **-nodes**.

5. Firmar el Certificado con la CA "Nueva"

> openssl x509 -CAkey cakey.pem -CA ca-NOMBRE-cert.pem -req -in serverrequest_ldap.pem -days 3650 -CAcreateserial -out servercert_ldap.pem -extensions 'aaron_req' -extfile extserver.cnf


6. Modificar el `install.sh` + `ldap.conf` + `slapd.conf` + `startup.sh`.

> install.sh

```
#! /bin/bash
# @keshi ASIX M11 2021-2022
# instal.lacio slapd edt.org
# -------------------------------------
mkdir /etc/ldap/certs

cp /opt/docker/ca_leomessi_cert.pem /etc/ldap/certs/. # PER PROVAR-SE A SI MATEIX COM A CLIENT
cp /opt/docker/ca_leomessi_cert.pem /etc/ssl/certs/. # Certificat de CA
cp /opt/docker/servercert_ldap.pem /etc/ldap/certs/. # Certificat del servidor

cp /opt/docker/serverkey_ldap.pem  /etc/ldap/certs/. # Key del servidor

#cp /opt/docker/servercertEXT.pem /etc/ldap/certs/.

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

```

> ldap.conf

```
BASE dc=edt,dc=org

URI ldap://ldap.edt.org

TLS_CACERT /etc/ldap/certs/ca_nombreInventado_cert.pem
TLS_CACERT /etc/ldap/certs/servercert_ldap.pem

```

> slapd.sh

```
TLSCACertificateFile        /etc/ldap/certs/ca_nombreInventado_cert.pem

TLSCertificateFile		/etc/ldap/certs/servercert_ldap.pem
TLSCertificateKeyFile       /etc/ldap/certs/serverkey_ldap.pem

TLSVerifyClient       never
#TLSCipherSuite        HIGH:MEDIUM:LOW:+SSLv2

```

> startup.sh

```


```

7. Modificar `/etc/hosts`

```
172.x.x.x	ldap.edt.org mysecureldapserver.org
127.0.0.1	localhost
```

7. Generar Docker.

8. Probar comandos: 

# Test LDAP

```
# ldapsearch -x -LLL -h 172.17.0.2 -s base -b 'dc=edt,dc=org' dn
dn: dc=edt,dc=org

# ldapsearch -x -LLL -Z -h 172.17.0.2 -s base -b 'dc=edt,dc=org' dn
dn: dc=edt,dc=org

# ldapsearch -x -LLL -ZZ -h 172.17.0.2 -s base -b 'dc=edt,dc=org' dn
dn: dc=edt,dc=org

# ldapsearch -x -LLL -H ldaps://172.17.0.2  -s base -b 'dc=edt,dc=org' dn
dn: dc=edt,dc=org

# ldapsearch -x -LLL -H ldaps://172.17.0.2:636  -s base -b 'dc=edt,dc=org' dn
dn: dc=edt,dc=org

# ldapsearch -x -LLL -ZZ -H ldaps://172.17.0.2 -s base -b 'dc=edt,dc=org' dn
ldap_start_tls: Operations error (1)
	additional info: TLS already started
```

```
# cat /etc/hosts
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
172.17.0.2 ldap.edt.org mysecureldapserver.org

# ldapsearch -x -LLL -H ldaps://ldap.edt.org -s base -b 'dc=edt,dc=org' dn
dn: dc=edt,dc=org
```

# Test del certificat

```
# openssl s_client -connect 172.17.0.2:636 < /dev/null 2> /dev/null | openssl x509 -noout -tex
```

# Test des de l'interior del container

```
# ldapsearch -x -LLL -ZZ -h 127.0.0.1 -s base
dn: dc=edt,dc=org
dc: edt
description: Escola del treball de Barcelona
objectClass: dcObject
objectClass: organization
o: edt.org

[root@ldap docker]# ldapsearch -x -LLL -H ldaps://127.0.0.1 -s base dn
dn: dc=edt,dc=org

[root@ldap docker]# ldapsearch -x -LLL -H ldaps://localhost -s base dn
dn: dc=edt,dc=org
```

# Test Subject Alternative Name

```
ldapsearch -x -LLL -H ldaps://mysecureldapserver.org -b 'dc=edt,dc=org'
```

