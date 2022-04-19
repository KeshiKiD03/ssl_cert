**Actuem com a CA...**

* **Generem clau privada simple i fabriquem certificat autosignat de veritat absoluta:**
```
openssl genrsa -out cakey.pem
openssl req -new -x509 -days 365 -key cakey.pem -out cacert.pem
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Country Name (2 letter code) [AU]:CA
State or Province Name (full name) [Some-State]:Barcelona
Locality Name (eg, city) []:bcn
Organization Name (eg, company) [Internet Widgits Pty Ltd]:VeritatAbsoluta
Organizational Unit Name (eg, section) []:Certificats
Common Name (e.g. server FQDN or YOUR name) []:veritat
Email Address []:veritat@edt.org
```

* **Generem clau privada del servidor:**
```
openssl genrsa -out serverkey.ldap.pem 4096
```

* **Podem generar clau pública del servidor però NO CAL:**
```
openssl rsa -in cakey.pem -pubout -out cakeypub.pem
```

* **Generem 'request' per el servidor LDAP:**
```
openssl req -new -x509 -days 365 -nodes -out servercert.ldap.pem -keyout serverkey.ldap.pem
Generating a RSA private key
..........+++++
.........+++++
writing new private key to 'serverkey.ldap.pem'
-----
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Country Name (2 letter code) [AU]:CA
State or Province Name (full name) [Some-State]:Catalunya
Locality Name (eg, city) []:Barcelona
Organization Name (eg, company) [Internet Widgits Pty Ltd]:edt
Organizational Unit Name (eg, section) []:ldap
Common Name (e.g. server FQDN or YOUR name) []:ldap.edt.org
Email Address []:ldap@edt.org
```

**Som el servidor LDAP...**

**Fem la petició (de firma) al servidor (VeritatAbsoluta), ens demanarà 'qui som':**

* **Obtenim la petició del 'request' al servidor VeritatAbsolut (CA):**
```
openssl req -new -key serverkey.ldap.pem -out serverrequest.ldap.pem
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Country Name (2 letter code) [AU]:CA
State or Province Name (full name) [Some-State]:Catalunya
Locality Name (eg, city) []:Barcelona
Organization Name (eg, company) [Internet Widgits Pty Ltd]:edt
Organizational Unit Name (eg, section) []:ldap
Common Name (e.g. server FQDN or YOUR name) []:ldap.edt.org
Email Address []:ldap@edt.org

Please enter the following 'extra' attributes
to be sent with your certificate request
A challenge password []:jupiter
An optional company name []:edt
```

**Tornem a ser CA...**

* **SIGNEM la 'request' enviada per LDAP, és genera 'cacert.srl':**
```
openssl x509 -CA cacert.pem -CAkey cakey.pem -req -in serverrequest.ldap.pem -CAcreateserial -days 365 -out servercert.ldap.pem
Signature ok
subject=C = CA, ST = Catalunya, L = Barcelona, O = edt, OU = ldap, CN = ldap.edt.org, emailAddress = ldap@edt.org
Getting CA Private Key
```

* **ALTERNATIVA: Signar la 'request' acceptant altres dominis com a sinònims adjuntant un fitxer de configuració:**
```
openssl x509 -CA cacert.pem -CAkey cakey.pem -req -in serverrequest.ldap.pem -out servercertPLUS.pem -CAcreateserial -extfile ext.alternate.conf -days 365
```

**DINS DEL DOCKER/SERVIDOR:**

* **Creem i inicialitzem docker:**
```
docker build -t rubeeenrg/tls21:ldaps .

docker run --rm -h ldap.edt.org --name ldap.edt.org --network 2hisix -d rubeeenrg/tls21:ldaps
```

**NOTA:** Els ports -p 389:389 -p 636:6363 no cal exposar-los cap a fora ja que ho farem local!

* **Comprovem que dins del docker funciona:**

**NOTA:** Afegir '-d1 (debug)' i '-v (verbose)' per mirar errors,
```
ldapsearch -x -ZZ -LLL -H ldap://ldap.edt.org -b 'dc=edt,dc=org'
ldapsearch -x -LLL -H ldaps://ldap.edt.org -b 'dc=edt,dc=org'

PLUS:

ldapsearch -x -LLL -H ldaps://mysecureldapserver.org -b 'dc=edt,dc=org'
```

**COM A CLIENT:**

* **Hem de modificar '/etc/hosts' i posar la IP del Docker:**
```
172.x.x.x	ldap.edt.org mysecureldapserver.org
127.0.0.1	localhost
```

* **Com a client, encara NO FUNCIONA, falta el següent:**
```
ldapsearch -x -LLL -H ldaps://ldap.edt.org -b 'dc=edt,dc=org'
ldapsearch -x -ZZ -LLL -H ldap://ldap.edt.org -b 'dc=edt,dc=org'
ldapsearch -x -LLL -H ldaps://mysecureldapserver.org -b 'dc=edt,dc=org'
ldapsearch -x -LLL -h 172.19.0.2 -b 'dc=edt,dc=org'
```

* **Hem de modificar al client l'arxiu '/etc/ldap/ldap.conf' i ficar-li la ruta del certifcat, per tant, hem de pasar-li el certificat de la CA creat anteriorment per extreure la clau pública i xequejar el servidor LDAPs:**
```
cp /var/tmp/m11/ssl21/tls:ldaps/cacert.pem /etc/ssl/certs/cacert.pem
cp /var/tmp/m11/ssl21/tls:ldaps/servercertPLUS.pem /etc/ssl/certs/servercertPLUS.pem
```

* **ARXIU '/etc/ldap/ldap.conf':**
```
TLS_CACERT	/etc/ssl/certs/cacert.pem
TLS_CACERT	/etc/ssl/certs/servertcertPLUS.pem
```

**NOTA:** El client necessita saber a quina entitat (CA) preguntar sobre la veracitat del servidor al que s'està connectant.
