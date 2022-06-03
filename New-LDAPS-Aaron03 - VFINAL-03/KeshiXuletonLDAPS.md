# LDAPS
## @isx36579183 ASIX M11-SAD Curs 2021-2022
-----------

1. Generar clave CA:

__openssl genrsa -out cakey.pem 1024__

2. Generar req autosing CA FORMATO PEM:

__openssl req -new -x509 -nodes -sha1 -days 365 -key cakey.pem -out ca_andal_cert.pem__ 

Country Name (2 letter code) [AU]:CA
State or Province Name (full name) [Some-State]:Catalunya
Locality Name (eg, city) []:Barcelona
Organization Name (eg, company) [Internet Widgits Pty Ltd]:Veritat Andal
Organizational Unit Name (eg, section) []:veritat
Common Name (e.g. server FQDN or YOUR name) []:aaron.edt.org
Email Address []:aaron@edt.org
keshi@KeshiKiD03:~/Documents/ss

3. Crear fichero `myserver.cnf` a partir de `/etc/ssl/openssl.cnf`

[ v3_req ]

# Extensions to add to a certificate request
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = @alt_names

[ alt_names ]
DNS.0 = __aaron.edt.org__
DNS.1 = mysecureldapserver.org
DNS.2 = ldap
IP.1 = __172.19.0.2__
IP.2 = 127.0.0.1

4. Crear el fichero `ext.alternate.conf` = Plantilla de SubAlternateName.

basicConstraints=CA:FALSE
extendedKeyUsage=serverAuth
subjectAltName=IP:__172.19.0.2__,IP:127.0.0.1,email:copy,DNS:mysecureldapserver.org,DNS:ldap

5. Generar key server y req del server con su config (a partir del config en el fichero myserver.cnf):

__openssl req -newkey rsa:2048 -nodes -sha256 -keyout serverkey.ldap.pem -out req-server.pem -config myserver.cnf__

Country Name (2 letter code) [CA]:
State or Province Name (full name) [Barcelona]:
Locality Name (eg, city) []:Barcelona
Organization Name (eg, company) [ldap]:
Organizational Unit Name (eg, section) [info]:edt
Common Name (e.g. server FQDN or YOUR name) []:ldap.edt.org
Email Address []:ldap@edt.org

Please enter the following 'extra' attributes
to be sent with your certificate request
A challenge password []:
An optional company name []:


6. Firmar el cert y generar el certificado con la CA veritat absoluta montar imagen docker con certs y listo:

__openssl x509 -CAkey cakey.pem -CA ca_andal_cert.pem -req -in req-server.pem -days 3650 -CAcreateserial -out servercert.ldap.pem -extensions 'v3_req' -extfile myserver.cnf__

Signature ok
subject=C = CA, ST = Barcelona, L = Barcelona, O = ldap, OU = edt, CN = ldap.edt.org, emailAddress = ldap@edt.org
Getting CA Private Key


7. Editar `install.sh` + `slapd.conf` + `ldap.conf` + `startup.sh`

`install.sh`

mkdir /etc/ldap/certs

cp /opt/docker/ca_andal_cert.pem /etc/ldap/certs/. # PER PROVAR-SE A SI MATEIX COM A CLIENT
cp /opt/docker/ca_andal_cert.pem /etc/ssl/certs/. # Certificat de CA
cp /opt/docker/servercert.ldap.pem /etc/ldap/certs/. # Certificat del servidor

cp /opt/docker/serverkey.ldap.pem  /etc/ldap/certs/. # Key del servidor

cp /opt/docker/serverkey.ldap.pem  /etc/ldap/certs/. # Key del servidor


rm -rf /etc/ldap/slapd.d/*
rm -rf /var/lib/ldap/*

cp /opt/docker/slapd.conf /etc/ldap/slapd.conf

slaptest -f /opt/docker/slapd.conf -F /etc/ldap/slapd.d # Provem i ensamblem el servidor LDAP
slaptest -u -f /opt/docker/slapd.conf -F /etc/ldap/slapd.d

slapadd -F /etc/ldap/slapd.d -l /opt/docker/edt.org.ldif # Populate de LDAP
chown -R openldap.openldap /etc/ldap/slapd.d /var/lib/ldap

cp /opt/docker/ldap.conf /etc/ldap/ldap.conf # Necesari per probar-se a si mateix


`slapd.conf`

TLSCACertificateFile        /etc/ldap/certs/ca_andal_cert.pem

TLSCertificateFile              /etc/ldap/certs/servercert.ldap.pem

TLSCertificateKeyFile       /etc/ldap/certs/serverkey.ldap.pem

TLSVerifyClient       never
#TLSCipherSuite        HIGH:MEDIUM:LOW:+SSLv2


`ldap.conf` (Server)

BASE    dc=edt,dc=org
URI     ldap://ldap.edt.org

#SIZELIMIT      12
#TIMELIMIT      15
#DEREF          never

# TLS certificates (needed for GnuTLS)

TLS_CACERT      /etc/ldap/certs/ca_andal_cert.pem
TLS_CACERT      /etc/ldap/certs/servercert.ldap.pem

`ldap.conf` (Host Local)

BASE    dc=edt,dc=org
URI     ldap://ldap.edt.org

#SIZELIMIT      12
#TIMELIMIT      15
#DEREF          never

# TLS certificates (needed for GnuTLS)

TLS_CACERT      /etc/ldap/certs/ca_andal_cert.pem
TLS_CACERT      /etc/ldap/certs/servercert.ldap.pem

8. Editar `/etc/hosts` (Host Local)

172.19.0.2	ldap.edt.org mysecureldapserver.org
127.0.0.1	localhost

9. Build & deploy docker.

docker build -t keshikid03/ssl22:ldaps_vExt .

docker run --rm --name ldap.edt.org -h ldap.edt.org --net 2hisx -d keshikid03/ssl22:ldaps_vExt

NOTA: Vigilar los permisos

sudo chmod 665 *

sudo chmod 775 install.sh startup.sh

10. Poner el certificado de la CA '`ca_andal_cert.pem`' en `/etc/ldap/certs` (Tiene que existir).

sudo cp ca_andal_cert.pem /etc/ldap/certs

11. Pruebas de ldapsearch INSEGURO, SEGURO, STARTS Z ZZ Y SUBJECT ALTERNATE NAME.

 2052  ldapsearch -x -LLL -H ldap://ldap.edt.org -s base 
 
 OK

 2053  ldapsearch -x -LLL -H ldap://ldap.edt.org -s base 
 
 OK

 2054  ldapsearch -x -LLL -H ldaps://ldap.edt.org -s base

 OK

 2062  ldapsearch -x -LLL -H ldap://ldap.edt.org -s base

 OK

 2063  ldapsearch -x -LLL -H ldaps://ldap.edt.org -s base

 OK

 2064  ldapsearch -x -LLL -H ldaps://mysecureldapserver.org -s base

 OK

 2065  ldapsearch -x -LLL -Z -H ldap://ldap.edt.org -s base

 OK

 2066  ldapsearch -x -LLL -ZZ -H ldap://ldap.edt.org -s base

 OK

 2067  ldapsearch -x -LLL -ZZ -H ldap://mysecureldapserver.org -s base

 OK

 2068  ldapsearch -x -LLL -Z -H ldap://mysecureldapserver.org -s base

OK

 2075  cd $HOME

 2076  ldapsearch -x -LLL -ZZ -H ldaps://172.19.0.2 -s base

isx36579183@i11:/etc/ldap$ ldapsearch -x -LLL -ZZ -H ldaps://172.19.0.2 -s base
ldap_start_tls: Operations error (1)
	additional info: TLS already started


 2077  ldapsearch -x -LLL -Z -h 172.19.0.2 -s base



openssl x509 --noout -text -in servercert.ldap.pem 













# RECUPERACIÓN LDAPS

1. Plantilla LDAPS (Nueva carpeta)

Dockerfile    ext.alternate.conf  ldap.conf     README.md   startup.sh
edt.org.ldif  install.sh          myserver.cnf  slapd.conf

2. __Crear certificados__: 

1. Generar clave CA:

__openssl genrsa -out cakey.pem 1024__

2. Generar req autosing CA FORMATO PEM:

__openssl req -new -x509 -nodes -sha1 -days 1000 -key cakey.pem -out ca_andal_cert.pem__ 

* Verificar el CERTIFICADO:

*   `openssl x509 -noout -text -in ca_andal_cert.pem` 

Country Name (2 letter code) [AU]:__CA__
State or Province Name (full name) [Some-State]:__Catalunya__
Locality Name (eg, city) []:__Barcelona__
Organization Name (eg, company) [Internet Widgits Pty Ltd]:__Veritat Andal__
Organizational Unit Name (eg, section) []:__veritat__
Common Name (e.g. server FQDN or YOUR name) []:__aaron.edt.org__
Email Address []:__aaron@edt.org__


3. Crear fichero `myserver.cnf` a partir de `/etc/ssl/openssl.cnf`

[ v3_req ]

# Extensions to add to a certificate request
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = @alt_names

[ alt_names ]
DNS.0 = __aaron.edt.org__
DNS.1 = mysecureldapserver.org
DNS.2 = ldap
IP.1 = __172.19.0.2__
IP.2 = 127.0.0.1

4. Crear el fichero `ext.alternate.conf` = Plantilla de SubAlternateName.

basicConstraints=CA:FALSE
extendedKeyUsage=serverAuth
subjectAltName=IP:__172.19.0.2__,IP:127.0.0.1,email:copy,DNS:mysecureldapserver.org,DNS:ldap

5. Generar key server y req del server con su config (a partir del config en el fichero myserver.cnf):

__openssl req -newkey rsa:2048 -nodes -sha256 -keyout serverkey.ldap.pem -out req-server.pem -config myserver.cnf__

Country Name (2 letter code) [CA]:
State or Province Name (full name) [Barcelona]:
Locality Name (eg, city) []:Barcelona
Organization Name (eg, company) [ldap]:
Organizational Unit Name (eg, section) [info]:edt
Common Name (e.g. server FQDN or YOUR name) []:ldap.edt.org
Email Address []:ldap@edt.org

Please enter the following 'extra' attributes
to be sent with your certificate request
A challenge password []:
An optional company name []:


6. Firmar el cert y generar el certificado con la CA veritat absoluta montar imagen docker con certs y listo:

__openssl x509 -CAkey cakey.pem -CA ca_andal_cert.pem -req -in req-server.pem -days 3650 -CAcreateserial -out servercert.ldap.pem -extensions 'v3_req' -extfile myserver.cnf__

Signature ok
subject=C = CA, ST = Barcelona, L = Barcelona, O = ldap, OU = edt, CN = ldap.edt.org, emailAddress = ldap@edt.org
Getting CA Private Key

* Verificar el CERTIFICADO:

*   `openssl x509 -noout -text -in servercert.ldap.pem` 

            X509v3 Subject Alternative Name: 
                DNS:aaron.edt.org, DNS:mysecureldapserver.org, DNS:ldap, IP Address:172.19.0.2, IP Address:172.0.0.1


7. Modificar el `install.sh` + `ldap.conf` + `slapd.conf` + `startup.sh`.

> install.sh

```
#! /bin/bash
# @keshi ASIX M11 2021-2022
# instal.lacio slapd edt.org
# -------------------------------------
mkdir /etc/ldap/certs

cp /opt/docker/ca_andal_cert.pem /etc/ldap/certs/. # PER PROVAR-SE A SI MATEIX COM A CLIENT
cp /opt/docker/ca_andal_cert.pem /etc/ssl/certs/. # Certificat de CA
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

```

> ldap.conf

```
BASE	dc=edt,dc=org
URI	ldap://ldap.edt.org



TLS_CACERT	/etc/ldap/certs/ca_andal_cert.pem
TLS_CACERT	/etc/ldap/certs/servercert.ldap.pem


```

> slapd.conf

```
# Especificar CA Cert

TLSCACertificateFile        /etc/ldap/certs/ca_andal_cert.pem

# Especificar LDAP Cert

TLSCertificateFile          /etc/ldap/certs/servercert.ldap.pem

# Especificar LDAP Key

TLSCertificateKeyFile       /etc/ldap/certs/serverkey.ldap.pem

TLSVerifyClient       never
#TLSCipherSuite        HIGH:MEDIUM:LOW:+SSLv2


```

> startup.sh

```
#! /bin/bash

/opt/docker/install.sh && echo "Install Ok"

# Detach

#/usr/sbin/slapd -d0

# Detach with LDAPS

/usr/sbin/slapd -d0 -u openldap -h "ldap:/// ldaps:/// ldapi:///"

# Interactive with LDAPS

# /usr/sbin/slapd -u openldap -h "ldap:/// ldaps:/// ldapi:///"


```

7. Modificar `/etc/hosts`

```
172.x.x.x	ldap.edt.org mysecureldapserver.org
127.0.0.1	localhost
```

7. Generar Docker.


_NOTA: Vigilar los permisos_

__sudo chmod 665 *__

__sudo chmod 775 install.sh startup.sh__

docker build -t keshikid03/ssl22:ldaps_v1 .

docker network create 2hisx

```
docker run --rm --name ldap.edt.org -h ldap.edt.org --net 2hisx -d keshikid03/ssl22:ldaps_vExt2
```

# HOST LOCAL (IMPORTANTE)

* Una vez hecho el DEPLOY DE Docker añadir el __CERT DE LA CA__ en el cliente en `/etc/ldap/certs` (Importante crear la carpeta antes).

* Modificar el __ldap.conf__ y añadir esta línea:

```
BASE	dc=edt,dc=org
URI	ldap://ldap.edt.org

TLS_CACERT /etc/ldap/certs/ca_ronaldo_cert.pem

```


8. Probar comandos: 

1. ldapsearch -x -LLL -H ldaps://ldap.edt.org -s base 

Ldap Seguro por el puerto 636

2. ldapsearch -d1 -x -LLL -H ldaps://ldap.edt.org -s base 

> DEBUG port 636

* STARTLS

3. ldapsearch -x -LLL -Z -H ldap://ldap.edt.org -s base

> (Inicia STARTLS pero si da ERROR no pasa nada si no usas Startls. Pero funciona igualmente, si puedes lo usas porfa)

4. ldapsearch -d1 -x -LLL -Z -H ldap://ldap.edt.org -s base

> DEBUG port 389

5. ldapsearch -x -LLL -ZZ -H ldap://ldap.edt.org -s base

> (Inicia y obliga a usar forzadamente STARTLS)

6. ldapsearch -d1 -x -LLL -ZZ -H ldap://ldap.edt.org -s base

> DEBUG port 389

7. ldapsearch -x -ZZ -H ldap://ldap.edt.org -d1 dn 2> log 

> (Inicia y obliga a usar forzadamente STARTLS. Tiene -d1 para debug del “dialogo”). Va por el puerto inseguro 389. Lo guarda en un LOG y muestra por pantalla el resultado.

8. ldapsearch -x -LLL -h 172.18.0.2 -s base

> (Conexión normal especificando host en lugar de URI + base manualmente)

9. # ldapsearch -x -LLL -ZZ -H ldaps://172.18.0.2 -s base -b 'dc=edt,dc=org' dn

ldap_start_tls: Operations error (1)
	additional info: TLS already started

10. `ldapsearch -x -LLL -H ldaps://mysecureldapserver.org -b 'dc=edt,dc=org' -s base`

11. 

12. 

13. 

# Test LDAP

```
# ldapsearch -x -LLL -h 172.18.0.2 -s base -b 'dc=edt,dc=org' dn
dn: dc=edt,dc=org

# ldapsearch -x -LLL -Z -h 172.18.0.2 -s base -b 'dc=edt,dc=org' dn
dn: dc=edt,dc=org

# ldapsearch -x -LLL -ZZ -h 172.18.0.2 -s base -b 'dc=edt,dc=org' dn
dn: dc=edt,dc=org

# ldapsearch -x -LLL -H ldaps://172.18.0.2  -s base -b 'dc=edt,dc=org' dn
dn: dc=edt,dc=org

# ldapsearch -x -LLL -H ldaps://172.18.0.2:636  -s base -b 'dc=edt,dc=org' dn
dn: dc=edt,dc=org

# ldapsearch -x -LLL -ZZ -H ldaps://172.18.0.2 -s base -b 'dc=edt,dc=org' dn
ldap_start_tls: Operations error (1)
	additional info: TLS already started
```

```
# cat /etc/hosts
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
172.17.0.2 ldap.edt.org mysecureldapserver.org

# ldapsearch -x -LLL -H ldaps://ldap.edt.org -s base -b 'dc=edt,dc=org' dn
dn: dc=edt,dc=org

dn: dc=edt,dc=org
dc: edt
description: Escola del treball de Barcelona
objectClass: dcObject
objectClass: organization
o: edt.org


```

# Test del certificat

```
# openssl s_client -connect 172.19.0.2:636 < /dev/null 2> /dev/null | openssl x509 -noout -text


isx36579183@i11:/etc/ldap$ openssl s_client -connect 172.19.0.2:636 < /dev/null 2> /dev/null | openssl x509 -noout -text
Certificate:
    Data:
        Version: 3 (0x2)
        Serial Number:
            1f:d2:ee:d7:a5:50:32:2d:05:2a:59:d1:63:9b:76:2d:5d:30:82:9b
        Signature Algorithm: sha256WithRSAEncryption
        Issuer: C = CA, ST = Catalunya, L = Barcelona, O = Veritat Andal, OU = veritat, CN = aaron.edt.org, emailAddress = aaron@edt.org
        Validity
            Not Before: Apr 22 19:31:21 2022 GMT
            Not After : Apr 19 19:31:21 2032 GMT
        Subject: C = CA, ST = Barcelona, L = Barcelona, O = ldap, OU = edt, CN = ldap.edt.org, emailAddress = ldap@edt.org
        Subject Public Key Info:
            Public Key Algorithm: rsaEncryption
                RSA Public-Key: (2048 bit)
                Modulus:
                    00:d7:4f:13:74:1f:90:ce:e1:44:8f:b3:86:81:58:
                    de:17:c4:3c:d5:9c:37:05:a0:62:8f:d2:15:4f:00:
                    6c:02:8a:b8:36:53:11:4b:b6:e3:cd:99:e2:7a:55:
...

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
ldapsearch -x -LLL -H ldaps://mysecureldapserver.org -b 'dc=edt,dc=org' -s base
```

OK

















----------
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

* Verificar: 

    * `openssl rsa --noout -text -in cakey.pem`

    RSA Private-Key: (1024 bit, 2 primes)

    * `file cakey.pem`

    cakey.pem: PEM RSA private key

2. Generar el CA "Inventado" en formato PEM.

> openssl req -new -x509 -days 365 -key cakey.pem -out ca-NOMBRE-cert.pem 

* Verificar:

    * `openssl x509 -noout -text -in ca-NOMBRE-cert.pem`


3. Modificar el `extserver.cnf` para LDAP.

```
[ aaron_req ]

# Extensions to add to a certificate request
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = @alt_names

[ alt_names ]
DNS.0 = aaron.edt.org
DNS.1 = mysecureldapserver.org
DNS.2 = ldap
IP.1 = [IPDocker]
IP.2 = 127.0.0.1
```


4. Generar una __request__ donde se emitirá la `Key Server (serverkey_ldap)` y `Request Server (serverrequest_ldap)` a partir de una configuración especial (__extserver.cnf__) para LDAP; CA:False.

> openssl req -newkey rsa:2048 -sha256 -keyout serverkey_ldap.pem -out serverrequest_ldap.pem -config extserver.cnf.

* Con este comando generamos un 3x1 - Generamos un par de Claves y genera la request al mismo. 

> password: Jupiter

* Verificar la __REQUEST__:

    * `openssl req -noout -text -in serverrequest_ldap.pem`

* **-newkey** la clave privada a fabricar sea del tipo RSA:2048

* **-keyout** creará una clave privada con la fabricación del CERTIFICADO, sin password

* **-days** --> Caducidad.

* **Pide passphrase** porque no ha puest **-nodes**.

5. Firmar el Certificado y Generarla con la firma de la CA "Nueva".

> openssl x509 -CAkey cakey.pem -CA ca-NOMBRE-cert.pem -req -in serverrequest_ldap.pem -days 3650 -CAcreateserial -out servercert_ldap.pem -extensions 'aaron_req' -extfile extserver.cnf

Signature ok
subject=C = CA, ST = catalunya, L = barcelona, O = edt, OU = ldap, CN = ldap.edt.org, emailAddress = ldap@edt.org
Getting CA Private Key


* Verificar:

*   `openssl x509 -noout -text -in servercert_ldap.pem` 



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
BASE	dc=edt,dc=org
URI	ldap://ldap.edt.org



TLS_CACERT	/etc/ldap/certs/ca_ronaldo_cert.pem
TLS_CACERT	/etc/ldap/certs/servercert_ldap.pem


```

> slapd.sh

```
# Especificar CA Cert

TLSCACertificateFile        /etc/ldap/certs/ca_ronaldo_cert.pem

# Especificar LDAP Cert

TLSCertificateFile          /etc/ldap/certs/servercert_ldap.pem

# Especificar LDAP Key

TLSCertificateKeyFile       /etc/ldap/certs/serverkey_ldap.pem

TLSVerifyClient       never
#TLSCipherSuite        HIGH:MEDIUM:LOW:+SSLv2


```

> startup.sh

```
#! /bin/bash

/opt/docker/install.sh && echo "Install Ok"

# Detach

#/usr/sbin/slapd -d0

# Detach with LDAPS

/usr/sbin/slapd -d0 -u openldap -h "ldap:/// ldaps:/// ldapi:///"

# Interactive with LDAPS

# /usr/sbin/slapd -u openldap -h "ldap:/// ldaps:/// ldapi:///"


```

7. Modificar `/etc/hosts`

```
172.x.x.x	ldap.edt.org mysecureldapserver.org
127.0.0.1	localhost
```

7. Generar Docker.

docker build -t keshikid03/ssl22:ldaps .

docker network create 2hisx

```
docker run --rm --name ldap.edt.org -h ldap.edt.org --net 2hisx -d keshikid03/ssl22:ldaps
```

# HOST LOCAL (IMPORTANTE)

* Una vez hecho el DEPLOY DE Docker añadir el __CERT DE LA CA__ en el cliente en `/etc/ldap/certs` (Importante crear la carpeta antes).

* Modificar el __ldap.conf__ y añadir esta línea:

```
BASE	dc=edt,dc=org
URI	ldap://ldap.edt.org

TLS_CACERT /etc/ldap/certs/ca_ronaldo_cert.pem

```


8. Probar comandos: 

1. ldapsearch -x -LLL -H ldaps://ldap.edt.org -s base 

Ldap Seguro por el puerto 636

2. ldapsearch -d1 -x -LLL -H ldaps://ldap.edt.org -s base 

> DEBUG port 636

* STARTLS

3. ldapsearch -x -LLL -Z -H ldap://ldap.edt.org -s base

> (Inicia STARTLS pero si da ERROR no pasa nada si no usas Startls. Pero funciona igualmente, si puedes lo usas porfa)

4. ldapsearch -d1 -x -LLL -Z -H ldap://ldap.edt.org -s base

> DEBUG port 389

5. ldapsearch -x -LLL -ZZ -H ldap://ldap.edt.org -s base

> (Inicia y obliga a usar forzadamente STARTLS)

6. ldapsearch -d1 -x -LLL -ZZ -H ldap://ldap.edt.org -s base

> DEBUG port 389

7. ldapsearch -x -ZZ -H ldap://ldap.edt.org -d1 dn 2> log 

> (Inicia y obliga a usar forzadamente STARTLS. Tiene -d1 para debug del “dialogo”). Va por el puerto inseguro 389. Lo guarda en un LOG y muestra por pantalla el resultado.

8. ldapsearch -x -LLL -h 172.18.0.2 -s base

> (Conexión normal especificando host en lugar de URI + base manualmente)

9. # ldapsearch -x -LLL -ZZ -H ldaps://172.18.0.2 -s base -b 'dc=edt,dc=org' dn

ldap_start_tls: Operations error (1)
	additional info: TLS already started

10. `ldapsearch -x -LLL -H ldaps://mysecureldapserver.org -b 'dc=edt,dc=org' -s base`

11. 

12. 

13. 

# Test LDAP

```
# ldapsearch -x -LLL -h 172.18.0.2 -s base -b 'dc=edt,dc=org' dn
dn: dc=edt,dc=org

# ldapsearch -x -LLL -Z -h 172.18.0.2 -s base -b 'dc=edt,dc=org' dn
dn: dc=edt,dc=org

# ldapsearch -x -LLL -ZZ -h 172.18.0.2 -s base -b 'dc=edt,dc=org' dn
dn: dc=edt,dc=org

# ldapsearch -x -LLL -H ldaps://172.18.0.2  -s base -b 'dc=edt,dc=org' dn
dn: dc=edt,dc=org

# ldapsearch -x -LLL -H ldaps://172.18.0.2:636  -s base -b 'dc=edt,dc=org' dn
dn: dc=edt,dc=org

# ldapsearch -x -LLL -ZZ -H ldaps://172.18.0.2 -s base -b 'dc=edt,dc=org' dn
ldap_start_tls: Operations error (1)
	additional info: TLS already started
```

```
# cat /etc/hosts
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
172.17.0.2 ldap.edt.org mysecureldapserver.org

# ldapsearch -x -LLL -H ldaps://ldap.edt.org -s base -b 'dc=edt,dc=org' dn
dn: dc=edt,dc=org

dn: dc=edt,dc=org
dc: edt
description: Escola del treball de Barcelona
objectClass: dcObject
objectClass: organization
o: edt.org


```

# Test del certificat

```
# openssl s_client -connect 172.19.0.2:636 < /dev/null 2> /dev/null | openssl x509 -noout -text


isx36579183@i11:/etc/ldap$ openssl s_client -connect 172.19.0.2:636 < /dev/null 2> /dev/null | openssl x509 -noout -text
Certificate:
    Data:
        Version: 3 (0x2)
        Serial Number:
            1f:d2:ee:d7:a5:50:32:2d:05:2a:59:d1:63:9b:76:2d:5d:30:82:9b
        Signature Algorithm: sha256WithRSAEncryption
        Issuer: C = CA, ST = Catalunya, L = Barcelona, O = Veritat Andal, OU = veritat, CN = aaron.edt.org, emailAddress = aaron@edt.org
        Validity
            Not Before: Apr 22 19:31:21 2022 GMT
            Not After : Apr 19 19:31:21 2032 GMT
        Subject: C = CA, ST = Barcelona, L = Barcelona, O = ldap, OU = edt, CN = ldap.edt.org, emailAddress = ldap@edt.org
        Subject Public Key Info:
            Public Key Algorithm: rsaEncryption
                RSA Public-Key: (2048 bit)
                Modulus:
                    00:d7:4f:13:74:1f:90:ce:e1:44:8f:b3:86:81:58:
                    de:17:c4:3c:d5:9c:37:05:a0:62:8f:d2:15:4f:00:
                    6c:02:8a:b8:36:53:11:4b:b6:e3:cd:99:e2:7a:55:
...

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
ldapsearch -x -LLL -H ldaps://mysecureldapserver.org -b 'dc=edt,dc=org' -s base
```

OK



