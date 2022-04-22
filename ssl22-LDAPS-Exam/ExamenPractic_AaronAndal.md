# Examen Pràctic Aaron Andal

# Objectiu

**CA = Veritat Andal**

**-days 1000**

* openssl CA = __"Veritat Andal"__

    * Par de claves Pub/Priv para la CA --> ``cakey.pem``

    * CA inventado nuevo a partir de la KEY `cakey.pem` --> ``ca_andal_cert.pem ``
    * __Subject Alternative Name__ `ldaps://mysecureldapserver.org` a partir de una EXTENSIÓN `extserver.cnf`.

    * Generar `Key Server (serverkey_ldap.pem)` y `Request Server (serverrequest_ldap.pem)` a partir de `extserver.cnf`.

    * Par de claves Pub/Priv para el Servidor LDAP edt.org (_Passwordless_) --> ``serverkey_ldap.pem` 

    * Request de certificado para el Servidor LDAP edt.org a partir de Certificado de la CA (``ca_andal_cert.pem ``) (_Passwordless_) --> ```serverrequest_ldap.pem``

    * Certificado del Servidor de Ldap edt.org a partir del Request del Certificado (__Lo tiene que firmar__) --> ```servercert_ldap.pem``



* Deployment ldap21:group --> Docker al final


# Step by Step

1. Generar `PAR de CLAVES` de CA "Veritat Andal" CA:True

> openssl genrsa -out cakey.pem 1024

* Verificar: 

    * `openssl rsa -noout -text -in cakey.pem`

    RSA Private-Key: (1024 bit, 2 primes)

    * `file cakey.pem`

    cakey.pem: PEM RSA private key

2. Generar el CA "__Veritat Andal__" en formato PEM de __-days 1000__ a partir de la key rsa de __cakey.pem__.

> openssl req -new -x509 -days 1000 -key cakey.pem -out ca_andal_cert.pem

Country Name (2 letter code) [AU]:__CA__
State or Province Name (full name) [Some-State]:__Catalunya__
Locality Name (eg, city) []:__bcn__
Organization Name (eg, company) [Internet Widgits Pty Ltd]:__Veritat Andal__
Organizational Unit Name (eg, section) []:__veritatandal__    
Common Name (e.g. server FQDN or YOUR name) []:__andal.edt.org__
Email Address []:__andal@edt.org__

* Verificar el __Certificado de CA "Veritat Andal"__ con OpenSSL __x509__ (Comando para ver certificados).

```
openssl x509 -noout -text -in ca_andal_cert.pem
```

2. 