# Exercici(s) fet(s) a classe:

### Exercici 1:
* $: openssl genrsa -des3 --out cakey.pem --> genrsa (genera clau RSA), des3 (algorisme d'encriptació simètric), --out (perque no ho vomiti per pantalla), cakey.pem (nom del fitxer), 2048 (nº de bits de la clau) --> ENS DEMANARÀ PASSHPRASE: cakey.pem
* $ file cakey.pem --> Format "PEM" = text (DER + base 64 + capçalera + peu) | L'altre format és format ñes "DER" = binary
* $ cat cakey.pem --> No serveix de res (necessitem la "passphrase") --> El fitxer "cakey.pem" és la transformació de clau privada + encriptació "DES3"
* $ openssl rsa --noout --text -in cakey.pem --> Volem treballar amb la clau privada (rsa), noout(perque no ens vomiti la clau privada al final), text (per veure les dades), in (especificar fitxer) | Ens demana la "passphrase" per poder descodificar la clau privada
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
* $ openssl x509 --noout --text -in servercert.pem
* $ openssl x509 -noout -text -purpose -in servercert.pem --Z purpose (ens diu per a què serveix)
* $ vim ca.conf

```
basicConstraints= critical,CA:FALSE
extendedKeyUsage = serverAuth,emailProtection
```

* $ openssl x509 -CA cacert.pem -CAkey cakey.pem -req -in serverrequest.pem -CAcreateserial -days 360 -extfile ca.conf -out servercert.pem --> extfile --> ARA LI ESTEM DIENT PER A QUÈ SERVEIX EL CERTIFICAT (LI ESTEM PASSANT UN "MINI" FITXER DE CONFIGURACIÓ 
* $ openssl x509 -noout -text -in servercert.pem --> Comprovem
