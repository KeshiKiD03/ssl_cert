# How to Ldaps

# @keshi ASIX M11-SAD Curs 2021-2022

# Objetivos

1. Conectividad de LDAP con __Certificados TLS/SSL__. 

    --> `A partir de ldap21:group se generará ssl22:ldaps que tendrá certificados propios para el uso de TLS/SSL .`

2. Verificación de la creación de una __Entidad de Certificación__ nueva __"LeoMessi"__ 

    --> `Se creará la Entidad de Certificación a partir de Par de Claves Pub/Priv en el Servidor y generar Certificados de la misma, posteriormente su propagación`.

3. Verificación de comandos de __LDAP 389 y LDAPS 636 y STARTLS -Z / -ZZ__.

# Requisitos

* ldap21:group --> Docker

* openssl

    * Par de claves Pub/Priv para la CA (pass: _cakey_) --> ``cakey.pem``

    * CA inventado nuevo a partir de la CA (pass: _cakey_) --> ``ca_nombreInventado_cert.pem``

    * Par de claves Pub/Priv para el Servidor LDAP edt.org (_Passwordless_) --> ``serverkey_ldap.pem` 

    * Request de certificado para el Servidor LDAP edt.org a partir de Certificado de la CA (``ca_nombreInventado_cert.pem``) (_Passwordless_) --> ```serverrequest_ldap.pem``

    * Certificado del Servidor de Ldap edt.org a partir del Request del Certificado (__Lo tiene que firmar__) --> ```servercert_ldap.pem``

* slapd.conf

```
TLSCACertificateFile        /etc/ldap/certs/ca_nombreInventado_cert.pem

TLSCertificateFile		/etc/ldap/certs/servercertPLUS.pem
TLSCertificateKeyFile       /etc/ldap/certs/serverkey_ldap.pem

TLSVerifyClient       never
#TLSCipherSuite        HIGH:MEDIUM:LOW:+SSLv2
```

* ldap.conf 

    --> BASE dc=edt,dc=org

    --> URI ldap://ldap.edt.org

    --> TLS_CACERT /etc/ldap/certs/``ca_nombreInventado_cert.pem``.

* /etc/hosts -->  Contendrá --> ``ip_ldap       ldap.edt.org``

* /etc/ldap/certs --> Contendrá --> ``ca_nombreInventado_cert.pem``

# Procedimiento

1. Instalar openssl.

```
apt-get install openssl
```

2. Generar --> Par de claves Pub/Priv para la CA (pass: _cakey_) --> ``cakey.pem``

* Con DES3

```
openssl genrsa -des3 --out cakey.pem 2048
```

* Sin DES3 (no password)

```
openssl genrsa -out cakey.pem
```

* Verificar tipo de clave con file

```
file cakey.pem
```

* Verificar contenido de __cakey.pem__

```
openssl rsa --noout --text -in cakey.pem
```

3. Generar --> Par de claves Pub/Priv para el Servidor LDAP edt.org (_Passwordless_) --> ``serverkey_ldap.pem` 

```
openssl genrsa -out serverkey_ldap.pem 4096
```

* Verificar tipo de clave con file

```
file serverkey_ldap.pem
```

* Verificar contenido de __serverkey_ldap.pem__ OpenSSL rsa (Comando para ver certificados)

```
openssl rsa -noout -text -in serverkey_ldap.pem
```


* Sacar la clave pública a partir de par de claves privadas

```
openssl rsa -in serverkey_ldap.pem -pubout -out serverpub_ldap.pem
```


3. Generar --> CA inventado nuevo a partir de la CA (pass: _cakey_) --> ``ca_nombreInventado_cert.pem``

* Generamos la nueva __ENTIDAD DE CERTIFICACIÓN__ "LeoMessi".

```
openssl req -new -x509 -days 365 -key cakey.pem -out ca_leomessi_cert.pem
```

* Este comando se genera la __entidad de certificación__ + Genera el par de claves pub/priv (__Si anteriormente no lo tenemos creado__)

```
openssl req -new -x509 -days 365 -keyout cakey.pem -out ca_leomessi_cert.pem

```

* **-neykey** la clave privada a fabricar sea del tipo RSA:2048

* **-keyout** creará una clave privada con la fabricación del CERTIFICADO, sin password

* **-days** --> Caducidad.

* **Pide passphrase** porque no ha puest **-nodes**.


```
openssl req -new -x509 -days 365 -newkey rsa:2048 -keyout cakey.pem -out ca_leomessi_cert.pem
```

> PASSPHRASE: cakey


* Rellenamos los datos:


Passphrase: cakey

Country Name (2 letter code) [AU]:__CA__
State or Province Name (full name) [Some-State]:__catalunya__
Locality Name (eg, city) []:__barcelona__
Organization Name (eg, company) [Internet Widgits Pty Ltd]:__Leo Messi__
Organizational Unit Name (eg, section) []:__leomessi__
Common Name (e.g. server FQDN or YOUR name) []:__leo.edt.org__
Email Address []:__leo@edt.org__


* Verificar el __Certificado de CA "Leo Messi"__ con OpenSSL x509 (Comando para ver certificados).


```
openssl x509 -noout -text -in ca_leomessi_cert.pem
```

4. Generar --> __Certificado de Entidad__ para el Servidor LDAP edt.org a partir de Certificado de la CA (``ca_nombreInventado_cert.pem``) (_Passwordless_) --> ```servercert_ldap.pem``

```
openssl req -new -x509 -days 365 -nodes -key serverkey_ldap.pem -out servercert_ldap.pem
```


* Rellenamos los datos:


Country Name (2 letter code) [AU]:__CA__
State or Province Name (full name) [Some-State]:__catalunya__
Locality Name (eg, city) []:__barcelona__
Organization Name (eg, company) [Internet Widgits Pty Ltd]:__edt__
Organizational Unit Name (eg, section) []:__ldap__
Common Name (e.g. server FQDN or YOUR name) []:__ldap.edt.org__
Email Address []:__ldap@edt.org__


* Verificar el __Request de LDAP para su posterior certificado "ldap"__ con OpenSSL x509 (Comando para ver certificados).


```
openssl x509 -noout -text -in servercert_ldap.pem
```


5. __"Somos la entidad de LDAP"__ Generar --> La petición (request) de la firma al servidor (__Leo Messi__), nos pedirá quienes somos.Firma de la ``request`` por parte de la CA _Leo Messi (Veritat Absoluta)_ del __Servidor de Ldap edt.org__. 

    --> Se crea la petición de la firma de" ```serverrequest_ldap.pem``

```
openssl req -new -key serverkey_ldap.pem -out serverrequest_ldap.pem
```

Country Name (2 letter code) [AU]:__CA__
State or Province Name (full name) [Some-State]:__catalunya__
Locality Name (eg, city) []:__barcelona__
Organization Name (eg, company) [Internet Widgits Pty Ltd]:__edt__
Organizational Unit Name (eg, section) []:__ldap__
Common Name (e.g. server FQDN or YOUR name) []:__ldap.edt.org__
Email Address []:__ldap@edt.org__

Please enter the following 'extra' attributes
to be sent with your certificate request
A challenge password []:__jupiter__
An optional company name []:__edt__

> password: jupiter

* Verificar la __Petición de la firma del !Request del Certificado de LDAP" para su posterior generación de certificado "ldap"__ con OpenSSL x509 (Comando para ver certificados).

```
openssl req -noout -text -in serverrequest_ldap.pem
```

__Certificate Request:__
    Data:
        Version: 1 (0x0)
        Subject: C = CA, ST = catalunya, L = barcelona, O = edt, OU = ldap, CN = ldap.edt.org, emailAddress = ldap@edt.org
        Subject Public Key Info:
            Public Key Algorithm: rsaEncryption
                RSA Public-Key: (4096 bit)
                Modulus:
....
        Attributes:
            unstructuredName         :__edt__
            challengePassword        :__jupiter__



6. Volvemos a ser __CA Leo Messi__ --> Tenemos que firmar la `request` generada anteriormente por __LDAP__ (`serverrequest_ldap.pem`) y se genera "``cacert.srl``".

```
openssl x509 -CA ca_leomessi_cert.pem -CAkey cakey.pem -req -in serverrequest_ldap.pem -CAcreateserial -days 365 -out servercert_ldap.pem

```

> passphrase: cakey

Signature __ok__
subject=C = CA, ST = catalunya, L = barcelona, O = edt, OU = ldap, CN = ldap.edt.org, emailAddress = ldap@edt.org
Getting CA Private Key


* Verificar la __Petición de la firma del !Request del Certificado de LDAP" para su posterior generación de certificado "ldap"__ con OpenSSL x509 (Comando para ver certificados).

```
openssl x509 -noout -text -in servercert_ldap.pem
```



-----------------------------------------------------------------
* EXTRA: Firmar la "__request__" aceptando otros dominios como sinónimos adjuntando un __fichero de configuración__.

```
openssl x509 -CA ca_leomessi_cert.pem -CAkey cakey.pem -req -in serverrequest_ldap.pem -out servercertPLUS.pem -CAcreateserial -extfile ext.alternate.conf -days 365
```
-----------------------------------------------------------------

6. Deployment de nuevo Docker server ssl22:ldaps_vFinal modificando `install.sh` + `ldap.conf` + `slapd.conf`.

* install.sh

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
```

* ldap.conf

```
#
# LDAP Defaults
#

# See ldap.conf(5) for details
# This file should be world readable but not world writable.

BASE    dc=edt,dc=org
URI     ldap://ldap.edt.org
#URI    ldaps://ldap.edt.org #???

#SIZELIMIT      12
#TIMELIMIT      15
#DEREF          never

# TLS certificates (needed for GnuTLS)

TLS_CACERT      /etc/ldap/certs/ca_leomessi_cert.pem
```

* slapd.conf

```
TLSCACertificateFile        /etc/ldap/certs/ca_leomessi_cert.pem

#TLSCertificateFile          /etc/ldap/certs/servercert.ldap.pem

TLSCertificateFile              /etc/ldap/certs/servercert_ldap.pem
TLSCertificateKeyFile       /etc/ldap/certs/serverkey_ldap.pem

TLSVerifyClient       never
#TLSCipherSuite        HIGH:MEDIUM:LOW:+SSLv2
```

7. En Host Local exportar el ``ca_nombreInventado_cert.pem`` a ``/etc/ldap/certs`` (_Hay que crearlo a priori_).

8. Modificar el `ldap.conf` + `/etc/hosts`

9. Probar comandos de LDAP y LDAPS.