# Presentació LDAPS

### Ayuda: Presentacio-Ldaps.md + HowTOLdaps-New

1. git pull de ssl_cert e instalación de OpenSSL en Local.

2. Nombre de "Entidad CA" dada por Canet.

-
* openssl

    * Par de claves Pub/Priv para la CA (pass: _cakey_) --> ``cakey.pem``

    * CA inventado nuevo a partir de la CA (pass: _cakey_) --> ``ca_nombreInventado_cert.pem``

    * Par de claves Pub/Priv para el Servidor LDAP edt.org (_Passwordless_) --> ``serverkey_ldap.pem` 

    * Request de certificado para el Servidor LDAP edt.org a partir de Certificado de la CA (``ca_nombreInventado_cert.pem``) (_Passwordless_) --> ```serverrequest_ldap.pem``

    * Certificado del Servidor de Ldap edt.org a partir del Request del Certificado (__Lo tiene que firmar__) --> ```servercert_ldap.pem``
-

3. Generar par de CLAVES para la CA con password:

```
# Generar

openssl genrsa -des3 --out cakey.pem 2048

# Verificar

openssl rsa --noout --text -in cakey.pem
```

4. Generar par de CLAVES sin password para LDAP:

```
# Generar

openssl genrsa -out serverkey_ldap.pem 4096

# Verificar

openssl rsa -noout -text -in serverkey_ldap.pem

# Opcional - Sacar CPub a partir de Claves Privadas

openssl rsa -in serverkey_ldap.pem -pubout -out serverpub_ldap.pem

```

5. Generar un CERTIFICADO (pass: _cakey_) para la CA Nueva --> ``ca_nombreInventado_cert.pem``:

* Generamos la nueva __ENTIDAD DE CERTIFICACIÓN__ "LeoMessi".

#### This

```

# Generar CERT CA "Nuevo"

openssl req -new -x509 -days 365 -key cakey.pem -out ca_leomessi_cert.pem

```

-

* Este comando se genera la __entidad de certificación__ + Genera el par de claves pub/priv (__Si anteriormente no lo tenemos creado__)

#### Opc1 sin pass

```
openssl req -new -x509 -days 365 -keyout cakey.pem -out ca_leomessi_cert.pem

```

* **-neykey** la clave privada a fabricar sea del tipo RSA:2048

* **-keyout** creará una clave privada con la fabricación del CERTIFICADO, sin password

* **-days** --> Caducidad.

* **Pide passphrase** porque no ha puest **-nodes**.

#### Opc2 w rsa

```
openssl req -new -x509 -days 365 -newkey rsa:2048 -keyout cakey.pem -out ca_leomessi_cert.pem
```

> CON PASSWORD PASSPHRASE: cakey

-

```
# Verificar CERTIFICADO CA "Nuevo"

openssl x509 -noout -text -in ca_leomessi_cert.pem

```


6. Generar una REQUEST de Certificado para el Servidor de LDAP:

```

```

7. Firmar la REQUEST de la CA Nueva --> Se genera '__cacert.srl__':

```

```

8. Generar un CERTIFICADO para el Servidor de LDAP.

```

```

9. Generar un CERTIFICADO con EXT Alternate (Subject Alternative Name) --> ext.alternate.conf __subjectAltName=IP:ipDocker,IP:127.0.0.1,email:copy,URI:ldaps://mysecureldapserver.org__

> __ext.alternate.conf__

```
basicConstraints=CA:FALSE
extendedKeyUsage=serverAuth
subjectAltName=IP:[ipDocker]],IP:127.0.0.1,email:copy,URI:ldaps://mysecureldapserver.org
```

> __/etc/ssl/openssl.cnf__

```
FALTA
```

> Generar Certificado_

```
openssl x509 -CA ca_leomessi_cert.pem -CAkey cakey.pem -req -in serverrequest_ldap.pem -out servercertEXT.pem -CAcreateserial -extfile ext.alternate.conf -days 360
```


10. Modificar el `install.sh` + `ldap.conf` + `slapd.conf` + `startup.sh`.

> install.sh

```


```

> ldap.conf

```


```

> slapd.sh

```


```

> startup.sh

```


```

11. Generar Docker


12. Probar comandos de LDAP y LDAPS + STARLS.




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