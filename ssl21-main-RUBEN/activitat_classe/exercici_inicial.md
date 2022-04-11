# Exercici(s) fet(s) a classe:

### Exercici 1:
* $: openssl genrsa -des3 --out cakey.pem --> genrsa (genera clau RSA), des3 (algorisme d'encriptació simètric), --out (perque no ho vomiti per pantalla), cakey.pem (nom del fitxer), 2048 (nº de bits de la clau) --> ENS DEMANARÀ PASSHPRASE: cakey.pem
* $ file cakey.pem --> Format "PEM" = text (DER + base 64 + capçalera + peu) | L'altre format és format ñes "DER" = binary
* $ cat cakey.pem --> No serveix de res (necessitem la "passphrase") --> El fitxer "cakey.pem" és la transformació de clau privada + encriptació "DES3"
* $ openssl rsa --noout --text -in cakey.pem --> Volem treballar amb la clau privada (rsa), noout(perque no ens vomiti la clau privada al final), text (per veure les dades), in (especificar fitxer (request)) | Ens demana la "passphrase" per poder descodificar la clau privada
* $ openssl genrsa -out serverkey.pem 4096 --> si no posem algorisme d'encriptació, no encriptarà la clau
* $ openssl rsa --noout --text -in serverkey.pem --> Propietats matemàtiques de la clau (no ens demana "passhprase" ja que no està protegit)
* $ openssl rsa -des3 -in serverkey.pem -out serverkey2.pem --> Afegim "passhprase" al fitxer (generem amb "des3")
* $ cat serverkey2.pem --> Veiem que a la capçalera ens dona informació de que està encriptada
* $ openssl rsa --noout --text -in serverkey2.pem --> Llistem propietats matemàtiques
* $ openssl rsa -in serverkey.pem -pubout -out serverpub.pem --> Extreiem la clau pública de la privada
* $ openssl rsa -in serverkey.pem -outform DER -out serverkey.der --> Convertim "PEM" a "DER"
* $ file serverkey.der --> Ens dirà el seu format
* $ cat serverkey.der --> Info en format "binari"

**Altra forma:**

* $ cat serverkey.der | tail -n +2 | head -n -1 > /tmp/f1 --> Treiem capçalera + peu i generem fitxer
* $ base64 --decode /tmp/f1 > /tmp/key.der
* $ diff serverkey.der /tmp/key.der --> TOT OK, ÉS EL MATEIX

### Exercici 2 (Certificats):
* $ openssl req -new -x509 -nodes -out servercert.pem -keyout serverkey.pem --> req (request), x509 (estàndard que ens diu que es un certificat digital, això és així SEMPRE), nodes (sense encriptació), keyout (fabricar-la ara (es nova)) | RESUM: Ens fabriquem la clau privada i el certificat públic (no tenim clau pública ni request) --> EL CERTIFICAT ÉS AUTOSIGNAT | Ens demana dades (Country Name: CA, State..: Catalunya, Locality..: Barcelona, Organization Name...: edt, Organizational Unit...: m11, Common Name...: web.edt.org, Email...: admin@edt.org
* $ openssl x509 --noout --text -in servercert.pem --> Llistem certificat
* $ openssl x509 -noout -issuer -subject -purpose -dates -in servercert.pem --> Ídem al d'adalt però amb els camps que volem

**Ens carreguem tot i volvem a generar:**

* $ openssl req -new -x509 -days 365 -out servercert.pem -newkey rsa:2048 -keyout serverkey.pem --> days 365 (especifiquem quan dura el certificat), newkey rsa:2048 (sigui de tipus rsa de 2048) | SI NO DIEM RES ENS DEMANA PASSPHRASE
* $ cat serverkey.pem --> Comprovem que la clau esta encriptada
* $ openssl x509 -noout -issuer -subject -purpose -dates -in servercert.pem --> Comprovem que el certificat dura un any

**Ens carreguem tot i volvem a generar:**

* $ openssl genrsa -out cakey.pem --> Generem clau privada simple
* $ openssl req -new -x509 -days 365 -key cakey.pem -out cacert.pem --> Ens fabriquem certificat "juan palomo" pero amb la clau anteriorment creada (certificat autosignat)
* $ openssl x509 -noout -issuer -subject -dates -in cacert.pem --> Mostrem
* $ openssl genrsa -out serverkey.pem --> Generem clau privada de servidor

**Ara farem la petició al servidor:**

* $ openssl req -new -key serverkey.pem -out serverrequest.pem --> Si fem una petició, ens demanarà qui som

```
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Country Name (2 letter code) [AU]:Ca
State or Province Name (full name) [Some-State]:Cat
Locality Name (eg, city) []:bcn
Organization Name (eg, company) [Internet Widgits Pty Ltd]:escola del treball
Organizational Unit Name (eg, section) []:informatica
Common Name (e.g. server FQDN or YOUR name) []:web.edt.org
Email Address []:admin@edt.org

Please enter the following 'extra' attributes
to be sent with your certificate request
A challenge password []:jupiter
An optional company name []:edt
```
* $ openssl req --noout -text -in serverrequest.pem --> Mostrem (qui fa la petició + la clau pública)

**Ens tornem a "convertir" en CA:**

* $ openssl x509 -CA cacert.pem -CAkey cakey.pem -req -in serverrequest.pem -CAcreateserial -days 90 -out servercert.pem --> Com es diu el certificat de l'autoritat de certificació, com és diu la key | L' autorització de certificacio envia el certificat i el servidor comproba.
* $ openssl x509 --noout --text -in servercert.pem --> 
* $ openssl x509 -noout -text -purpose -in servercert.pem --Z purpose (ens diu per a què serveix)
* $ vim ca.conf

```
basicConstraints= critical,CA:FALSE
extendedKeyUsage = serverAuth,emailProtection
```

* $ openssl x509 -CA cacert.pem -CAkey cakey.pem -req -in serverrequest.pem -CAcreateserial -days 360 -extfile ca.conf -out servercert.pem --> extfile --> ARA LI ESTEM DIENT PER A QUÈ SERVEIX EL CERTIFICAT (LI ESTEM PASSANT UN "MINI" FITXER DE CONFIGURACIÓ 
* $ openssl x509 -noout -text -in servercert.pem --> Comprovem (in = request)

## Exercici 3 (Extensions):
* $ openssl rsa -noout -text -in cakey.pem --> Mirem la clau privada
* $ openssl x509 -noout --text -in cacert.pem --> Mirem la clau de certificat d'autorització

**Si no els tenim, els fabriquem:**
* $ openssl genrsa -out cakey.pem --> Fabriquem clau privada
* $ openssl req -new -x509 -key cakey.pem -days 365 -out cacert.pem --> Fabriquem certificat autosignat de vertitat absoluta

```
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Country Name (2 letter code) [AU]:ca
State or Province Name (full name) [Some-State]:barcelona
Locality Name (eg, city) []:bcn
Organization Name (eg, company) [Internet Widgits Pty Ltd]:VeritatAbsoluta 
Organizational Unit Name (eg, section) []:Certificats
Common Name (e.g. server FQDN or YOUR name) []:veritat
Email Address []:veritat@edt.org
```

* $ openssl x509 -noout -text -in cacert.pem --> Revisem el contingut
* $ vim alternate.conf

```
basicConstraints=CA:FALSE
extendedKeyUsage=serverAuth
subjectAltName=IP:172.17.0.2,IP:127.0.0.1,email:copy,URI:ldaps://mysecureldapserver.org
```

* $ openssl req -newkey rsa:2048 -nodes -keyout keys1.pem -out reqs1.pem --> Fabriquem 'request' i la 'key' d'una tacada --> Tots això és la clau del servidor

```
Generating a RSA private key
................................................................+++++
.................................................+++++
writing new private key to 'keys1.pem'
-----
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Country Name (2 letter code) [AU]:ca
State or Province Name (full name) [Some-State]:Barcelona
Locality Name (eg, city) []:bcn
Organization Name (eg, company) [Internet Widgits Pty Ltd]:server1
Organizational Unit Name (eg, section) []:web
Common Name (e.g. server FQDN or YOUR name) []:web.edt.org
Email Address []:wed@edt.org

Please enter the following 'extra' attributes
to be sent with your certificate request
A challenge password []:jupiter
An optional company name []:edt.org
```

* $ openssl req -noout -text -in reqs1.pem --> Veiem el contingut de la petició de certificat

**Farem que sóm una CA i emetem certificats per diferents clients**

* $ openssl x509 -CA cacert.pem -CAkey cakey.pem -req -in reqs1.pem -out cert1.pem --> Com a CA, fabriquem certificat | -CAkey (clau privada) | ENS DONARÀ ERROR PERQUÈ NO EXISTEIX 'cacert.srl', l'hem de fabricar...
* $ openssl x509 -CA cacert.pem -CAkey cakey.pem -req -in reqs1.pem -out cert1.pem -CAcreateserial --> Fabriquem el 'cacert.srl' (SERIAL)
* $ openssl x509 -noout -text -in cert1.pem --> Veiem contingut (NO HI HA EXTENSIONS!)
* $ openssl x509 -CA cacert.pem -CAkey cakey.pem -req -in reqs1.pem -out cert1.pem -CAcreateserial -extfile alternate.conf -days 360 --> -extfile (utilitzem fitxer d'extension) | encara que els fitxer estiguin creats, els sobreescriurà | ARA SI QUE HI HA EXTENSIONS
* $ vim alternate.conf

```
AFEGIM DNS --> AIXÍ ES COM HAURÍA D'ESTAR:
basicConstraints=CA:FALSE
extendedKeyUsage=serverAuth
subjectAltName=IP:172.17.0.2,IP:127.0.0.1,email:copy,URI:ldaps://mysecureldapserver.org,DNS:web,DNS:myweb.org
```

* $ openssl x509 -CA cacert.pem -CAkey cakey.pem -req -in reqs1.pem -out cert1.pem -CAcreateserial -extfile alternate.conf -days 360 --> Tornem a generar el certificat
* $ openssl x509 -noout -text -in cert1.pem --> Comprovem

**Fitxer global de configuració, openssl.cnf (ABANS) --> openssl.cnf (ARA):**

**/etc/pki --> pki = publick key infraestructure (AQUÍ ESTABA TOT A FEDORA)**

**tree -L 1 /etc/ssl/ --> A DEBIAN ESTÀ AQUÍ**

* $ vim exemple1.cfg

```
[ my_client ]
basicConstraints = CA:FALSE
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid,issuer:always

[ my_server ]
basicConstraints = CA:FALSE
nsCertType = server
nsComment = "OpenSSL Generated Server Certificate"
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid,issuer:always
extendedKeyUsage = serverAuth
keyUsage = digitalSignature, keyEncipherment

[ my_edt ]
basicConstraints = CA:FALSE
subjectKeyIdentifier=hash
authorityKeyIdentifier=keyid:always,issuer
basicConstraints = critical,CA:true
keyUsage = cRLSign, keyCertSign
```

* $ openssl x509 -CA cacert.pem -CAkey cakey.pem -req -in reqs1.pem -out cert1.pem -CAcreateserial -extfile exemple1.cfg -extensions my_client -days 360 --> extensions my_clients (li diem quina extensió volem utilitzar)
* $ openssl x509 -noout -text -in cert1.pem --> Revisem
* $ openssl x509 -CA cacert.pem -CAkey cakey.pem -req -in reqs1.pem -out cert1.pem -CAcreateserial -extfile exemple1.cfg -extensions my_server -days 360 --> Generem amb la extensió de 'my_server'
* $ openssl x509 -noout -text -in cer1.pem --> Revisem
* $ openssl x509 -CA cacert.pem -CAkey cakey.pem -req -in reqs1.pem -out cert1.pem -CAcreateserial -extensions v3_ca -days 360 --> v3_ca està en el fitxer per defecte (si no li especifiquem fitxer, utilitza el de per defecte)
* openssl x509 -noout -text -in cert1.pem --> Comprovem

## Exercici 4 (Fitxer de configuració):
* $ cp /etc/ssl/openssl.cnf . --> Copiem el fitxer original i l'editem
* $ vim openssl.cnf

**Comentaris dins del fitxer (en el meu directori amb el que fà cada cosa**

* $ mkdir certs newcerts private crl --> Creem dirs per la configuració
* $ mv cakey.pem private/ --> Movem la clau privada
* $ vim serial --> Creem fitxer

```
01
```

* $ touch index.txt --> Generem fitxer buit
* $ mkdir merda --> Creem directori per fitxers que no utiltizem XDDDD
* $ mv alternate.conf cert1.pem keys1.pem exemple1.cfg reqs1.pem merda/ --> Movem fitxers que no utilitzem XDDD
* $ vim openssl.conf

```
Dins de [ CA_default ]
dir = .

Dins de [ req_distinguished_name ]
[ req_distinguished_name ]		# Definim preguntes que ens farà el 'request'
countryName			= Country Name Pais (2 letter code)
countryName_default		= CA
countryName_min			= 2
countryName_max			= 2

stateOrProvinceName		= State or Province Name (lloc) (full name)
stateOrProvinceName_default	= Barcelona

localityName			= Locality Name (eg, city)
localityName_default		= Santaco

0.organizationName		= Organization Name (eg, company)
0.organizationName_default	= Escola del Treball

# we can do this but it is not needed normally :-)
#1.organizationName		= Second Organization Name (eg, company)
#1.organizationName_default	= World Wide Web Pty Ltd

organizationalUnitName		= Organizational Unit Name (eg, section)
#organizationalUnitName_default	=

commonName			= Common Name (e.g. server FQDN or YOUR name)
commonName_max			= 64

emailAddress			= Email Address
emailAddress_max		= 64

# SET-ex3			= SET extension number 3
```

* $ openssl req -new -config openssl.cnf -key merda/keys1.pem -out merda/req.pem --> Generem 'request'

```
TOT ENS SURT PER DEFECTE PERQUÈ HO HEM CONFIGURAT

You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Country Name Pais (2 letter code) [CA]:
State or Province Name (lloc) (full name) [Barcelona]:
Locality Name (eg, city) [Santaco]:
Organization Name (eg, company) [Escola del Treball]:
Organizational Unit Name (eg, section) []:edt
Common Name (e.g. server FQDN or YOUR name) []:papa
Email Address []:

Please enter the following 'extra' attributes
to be sent with your certificate request
A challenge password []:
An optional company name []:
```

* $ openssl ca -in merda/req.pem -config openssl.cnf -out cert.pem --> Fabriquem certificat a partir del 'request' (Actuem com a CA) | ENS DONA ERROR PERQUE ELS 'COUNTRYNAME' són diferents (hem posat ca en comptes de CA) --> No ens ho crea perquè no podem generar certificats en nom d'altres!!!
* $ vim openssl.cnf

```
policy = policy_anything
```

* $ openssl ca -in merda/req.pem -config openssl.cnf -out cert.pem --> Ara si ens ho crea

```
Using configuration from openssl.cnf
Check that the request matches the signature
Signature ok
Certificate Details:
        Serial Number: 1 (0x1)
        Validity
            Not Before: Apr  6 07:09:42 2022 GMT
            Not After : Apr  3 07:09:42 2032 GMT
        Subject:
            countryName               = CA
            stateOrProvinceName       = Barcelona
            localityName              = Santaco
            organizationName          = Escola del Treball
            organizationalUnitName    = edt
            commonName                = papa
        X509v3 extensions:
            X509v3 Basic Constraints: 
                CA:FALSE
            Netscape Comment: 
                OpenSSL Generated Certificate
            X509v3 Subject Key Identifier: 
                E2:E9:B1:11:52:11:EF:9E:47:92:9E:C2:B8:C7:2C:01:64:14:C0:6E
            X509v3 Authority Key Identifier: 
                keyid:D5:D6:AC:6C:B1:6F:C6:6B:DD:24:2D:20:4C:B4:E2:8A:65:72:50:D7

Certificate is to be certified until Apr  3 07:09:42 2032 GMT (3650 days)
Sign the certificate? [y/n]:y


1 out of 1 certificate requests certified, commit? [y/n]y
Write out database with 1 new entries
Data Base Updated

ENS GENERÀ NOU FITXER 'index'
```

* $ cat index.txt

```
V	320403070942Z		01	unknown	/C=CA/ST=Barcelona/L=Santaco/O=Escola del Treball/OU=edt/CN=papa
```

* $ cat serial

```
02
```

* $ tree

```
.
├── apache.md
├── apunts.md
├── cacert.pem
├── cacert.srl
├── ca.conf
├── cert.pem
├── certs
├── crl
├── exercici_inicial.md
├── index.txt
├── index.txt.attr
├── index.txt.old
├── ldaps.md
├── merda
│   ├── alternate.conf
│   ├── cert1.pem
│   ├── exemple1.cfg
│   ├── keys1.pem
│   ├── req.pem
│   └── reqs1.pem
├── newcerts
│   └── 01.pem
├── openssl.cnf
├── private
│   └── cakey.pem
├── serial
├── serial.old
├── servercert.pem
├── serverkey.pem
└── serverrequest.pem
```

* $ openssl x509 -noout -text -in newcerts/01.pem --> Comprovem primer certificat 'serial'
* $ openssl ca -in merda/req.pem -config openssl.cnf -out cert.pem --> Tornem a generar el mateix certificat que abans però ens informa de que no podem perquè ja l'hem creat

```
Using configuration from openssl.cnf
Check that the request matches the signature
Signature ok
ERROR:There is already a certificate for /C=CA/ST=Barcelona/L=Santaco/O=Escola del Treball/OU=edt/CN=papa
The matching entry has the following details
Type          :Valid
Expires on    :320403070942Z
Serial Number :01
File name     :unknown
Subject Name  :/C=CA/ST=Barcelona/L=Santaco/O=Escola del Treball/OU=edt/CN=papa
isx48062351@i24:/var/tmp/m11/tls21/activitat_classe$ 
```

* $ vim openssl.cnf

```
Afegim noves seccions dins de...

[ usr_cert ]

[ my_client ]
basicConstraints = CA:FALSE
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid,issuer:always

[ my_server ]
basicConstraints = CA:FALSE
nsCertType = server
nsComment = "OpenSSL Generated Server Certificate"
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid,issuer:always
extendedKeyUsage = serverAuth
keyUsage = digitalSignature, keyEncipherment

[ my_edt ]
basicConstraints = CA:TRUE
subjectKeyIdentifier=hash
authorityKeyIdentifier=keyid:always,issuer
basicConstraints = critical,CA:true
keyUsage = cRLSign, keyCertSign
```

* $ openssl req -new -config openssl.cnf -key merda/keys1.pem -out merda/req2.pem --> Generem request

```
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Country Name Pais (2 letter code) [CA]:US
State or Province Name (lloc) (full name) [Barcelona]:oklahoma
Locality Name (eg, city) [Santaco]:
Organization Name (eg, company) [Escola del Treball]:cia
Organizational Unit Name (eg, section) []:cia
Common Name (e.g. server FQDN or YOUR name) []:binladen
Email Address []:

Please enter the following 'extra' attributes
to be sent with your certificate request
A challenge password []:
An optional company name []:
```
* $ openssl req -new -config openssl.cnf -key merda/keys1.pem -out merda/req3.pem --> Generem un altre request

```
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Country Name Pais (2 letter code) [CA]:
State or Province Name (lloc) (full name) [Barcelona]:
Locality Name (eg, city) [Santaco]:
Organization Name (eg, company) [Escola del Treball]:
Organizational Unit Name (eg, section) []:
Common Name (e.g. server FQDN or YOUR name) []:inf
Email Address []:

Please enter the following 'extra' attributes
to be sent with your certificate request
A challenge password []:
An optional company name []:
```

* $ openssl ca -in merda/req3.pem -config openssl.cnf -extensions my_edt -out cert.pem --> Generem certificat utilitzant la extensió 'my_edt'

```
Using configuration from openssl.cnf
Check that the request matches the signature
Signature ok
Certificate Details:
        Serial Number: 2 (0x2)
        Validity
            Not Before: Apr  6 07:26:59 2022 GMT
            Not After : Apr  3 07:26:59 2032 GMT
        Subject:
            countryName               = CA
            stateOrProvinceName       = Barcelona
            localityName              = Santaco
            organizationName          = Escola del Treball
            commonName                = inf
        X509v3 extensions:
            X509v3 Subject Key Identifier: 
                E2:E9:B1:11:52:11:EF:9E:47:92:9E:C2:B8:C7:2C:01:64:14:C0:6E
            X509v3 Authority Key Identifier: 
                keyid:D5:D6:AC:6C:B1:6F:C6:6B:DD:24:2D:20:4C:B4:E2:8A:65:72:50:D7

            X509v3 Basic Constraints: critical
                CA:TRUE
            X509v3 Key Usage: 
                Certificate Sign, CRL Sign
Certificate is to be certified until Apr  3 07:26:59 2032 GMT (3650 days)
Sign the certificate? [y/n]:y


1 out of 1 certificate requests certified, commit? [y/n]y
Write out database with 1 new entries
Data Base Updated
```

* $ cat serial

```
04
```

## Exercici 5 (Client / Servidor 'ncat') --> Mirar pàgina 36 del HowTo (Mail Eduard) per + informació:
* $ ncat -ssl -k -l 8080 --> -ssl (fa de servidor amb ssl)
* $ openssl s_client -connect pop.gmail.com:995 --> Estem 'atacant' el servidor de gmail 'parlant' amb ssl
* $ telnet pop.gmail.com 25 --> Ens connectem amb text plà (EHLO localhost --> ara!)

```
Trying 142.251.5.109...
Connected to pop.gmail.com.
Escape character is '^]'.
220 smtp.gmail.com ESMTP bh16-20020a05600c3d1000b0038ceba454f9sm3847631wmb.20 - gsmtp
EHLO localhost
250-smtp.gmail.com at your service, [79.154.169.192]
250-SIZE 35882577
250-8BITMIME
250-STARTTLS
250-ENHANCEDSTATUSCODES
250-PIPELINING
250-CHUNKING
250 SMTPUTF8
MAIL FROM rubenrodriguezgarcia0
530 5.7.0 Must issue a STARTTLS command first. bh16-20020a05600c3d1000b0038ceba454f9sm3847631wmb.20 - gsmtp
STARTTLS
220 2.0.0 Ready to start TLS
^CConnection closed by foreign host.
```

* $ openssl s_client -connect imap.gmail.com:993 --> EStem 'atacant' el servidor d'imap 'parlant' amb ssl
* $ openssl s_server -cert merda/cert1.pem -key merda/keys1.pem --www -accept 50000 --> Engeguem servidor 'web' per el port 50000

```
Using default temp DH parameters
ACCEPT

EN UN NAVEGADOR... 
https://localhost:50000

DESPRÉS, S'AFEGEIX EL SEGÜENT:
Using default temp DH parameters
ACCEPT
140255154529600:error:14094418:SSL routines:ssl3_read_bytes:tlsv1 alert unknown ca:../ssl/record/rec_layer_s3.c:1543:SSL alert number 48
140255154529600:error:14094416:SSL routines:ssl3_read_bytes:sslv3 alert certificate unknown:../ssl/record/rec_layer_s3.c:1543:SSL alert number 46
140255154529600:error:14094416:SSL routines:ssl3_read_bytes:sslv3 alert certificate unknown:../ssl/record/rec_layer_s3.c:1543:SSL alert number 46
140255154529600:error:14094416:SSL routines:ssl3_read_bytes:sslv3 alert certificate unknown:../ssl/record/rec_layer_s3.c:1543:SSL alert number 46
```
