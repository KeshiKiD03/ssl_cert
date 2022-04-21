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

ldapsearch -x  -H ldap://ldap.edt.org # Lo usamos con -s base
(Insegura por el puerto 389)



# IMPORTANTE el fichero cacert.pem (Certificado de CA) en /etc/ssl/certs/.

ldapsearch -x  -H ldaps://ldap.edt.org 
(Segura por el puerto 636)






ldapsearch -d1 -x -LLL -H ldaps://ldap.edt.org 
(Seguro por el puerto 636 con debug -d1 y -LLL (Human Readable))




# USANT STARTLS: (Convierte un puerto INSEGURO en SEGURO)

ldapsearch -x -Z -H ldap://ldap.edt.org
(Inicia STARTLS pero si da ERROR no pasa nada si no usas Startls. Pero funciona igualmente, si puedes lo usas porfa)




ldapsearch -x -ZZ -H ldap://ldap.edt.org -s base
(Inicia y obliga a usar forzadamente STARTLS)




# Verificamos si van por el puerto INSEGURO

ldapsearch -d1 -x -ZZ -H ldap://ldap.edt.org
(Inicia STARTLS pero si da ERROR no pasa nada si no usas Startls. Tiene -d1 para debug del “dialogo”. Pero funciona igualmente, si puedes lo usas porfa) (Observamos que va por el puerto INSEGURO 389)




ldapsearch -d1 -x -ZZ -H ldap://ldap.edt.org
(Inicia y obliga a usar forzadamente STARTLS. Tiene -d1 para debug del “dialogo”) - Va por el puerto inseguro 389.





ldapsearch -x -ZZ -H ldap://ldap.edt.org -d1 dn 2> log 
(Inicia y obliga a usar forzadamente STARTLS. Tiene -d1 para debug del “dialogo”). Va por el puerto inseguro 389. Lo guarda en un LOG y muestra por pantalla el resultado.




# Otros

ldapsearch -x -LLL -h 172.19.0.2 -s base -b 'dc=edt,dc=org'
(Conexión normal especificando host en lugar de URI + base manualmente)



ldapsearch -x -LLL -Z -h 172.19.0.2 -s base -b 'dc=edt,dc=org’
(Intenta iniciar como STARTLS sin especificar la URI y como host, es correcto error -11) - NO FUNCIONA POR IP, EL CERTIFICADO SOLO FUNCIONA POR COMMON NAME - FQDN




ldapsearch -x -LLL -H ldaps://172.19.0.2 -s base -b 'dc=edt,dc=org'
(No funciona)  - NO FUNCIONA POR IP, EL CERTIFICADO SOLO FUNCIONA POR COMMON NAME - FQDN




----------------------------------------------------------------------------

# Comandos de OpenSSL

## Extra Subject Alternative Name EXT.ALTERNATE.CONF

__Atenció__ 

Si es genera un nou certificat cal generar de nou la imatge docker i fer el run, no podem simplement copiar-la en calent al container per fer el test perquè el certificat es carrega al slapd en temps de construccció (en fer _slaptest_) de la base de dades.

> Fitxer de extensions amb noms alternatius de host del servidor:

__ext.alternate.conf__

```
basicConstraints=CA:FALSE
extendedKeyUsage=serverAuth
subjectAltName=IP:172.17.0.2,IP:127.0.0.1,email:copy,URI:ldaps://mysecureldapserver.org
```

> Generar el certificat nou (utilitzem la CA de Veritat Absoluta perquè no sigui autosignat):

```
openssl x509 -CAkey cakey.pem -CA cacert.pem -req -in serverreq.ldap.pem -days 3650 -CAcreateserial -extfile ext.alternate.conf -out servercert.ldap.pem

Signature ok

subject=/C=ca/ST=barcelona/L=barcelona/O=edt/OU=informatica/CN=ldap.edt.org/emailAddress=ldap@edt.org

Getting CA Private Key
```

```
openssl x509 -CAkey cakey.pem -CA cacert.pem -req -in serverreq.ldap.pem -days 3650 -CAcreateserial -extfile ext.alternate.conf -out servercert.ldap.pem

RESUM DE TOT: Signar / crear un certificat per 'ldapserver'.
SIGNIFICAT INDIVIDUAL:
```


> __Verificar__

```
openssl x509 -noout -text -in servercert.ldap.pem
        ...
        X509v3 extensions:
            X509v3 Basic Constraints: 
                CA:FALSE
            X509v3 Extended Key Usage: 
                TLS Web Server Authentication
            X509v3 Subject Alternative Name: 
                IP Address:172.17.0.2, IP Address:127.0.0.1, email:ldap@edt.org, URI:ldaps://mysecureldapserver.org
```

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