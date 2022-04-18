docker run --rm --name ldap.edt.org -h ldap.edt.org --net 2hisix -d edtasixm11/tls18:ldaps

ldapsearch -x -h 172.19.0.3 -b 'dc=edt,dc=org' --> Fora del container

sudo vim /etc/hosts: --> fora del container

172.X.X.X	ldap.edt.org

## DINS DEL CONTAINER:

ldapsearch -x -h ldap.edt.org -b 'dc=edt,dc=org' | head

ldapsearch -x -LLL -H ldap://ldap.edt.org -s base --> Encara segueix sent insegur! --> port 389

ldapsearch -x -LLL -H ldaps://ldap.edt.org -s base --> Ara es tràfic segur! --> port 636

ldapsearch -d1 -x -LLL -H ldaps://ldap.edt.org -s base --> -d1 (veiem diàleg per comprobar que estem amb tràfic segur)

ldapsearch -x -LLL -Z -H ldaps://ldap.edt.org -s base --> -Z (Si pots utiltiza startls)

ldapsearch -x -LLL -ZZ -H ldap://ldap.edt.org -s base --> -ZZ (Utilitza startls SÍ O SÍ) --> Hem de treure-li la 's' a ldap per fer-ho

## FORA DEL CONTAINER:

ldapsearch -x -LLL -H ldaps://172.17.0.2 -s base -b 'dc=edt,dc=org' --> Ens retorna error perquè no tenim configurada la CA.

## DINS DEL CONTAIENR:

cat ldap.conf --> TLS_CACERT /opt/docker/cacert.pem (FITXER AMB CA)

## FORA DEL CONTAINER:

sudo cp /etc/ldap/ldap.conf /etc/ldap/ldap.conf.install --> Fem una copia del fitxer

sudo vim /etc/ldap/ldap.conf --> Editem el fitxer

```
TLS_CACERT /tmp/cacert.pem
```

docker cp ldap.edt.org:/opt/docker/cacert.pem /tmp --> Copiem el certificat del docker a 'tmp' local

openssl x509 -noout --text -in /tmp/cacert.pem --> Mirem el certificat

ldapsearch -x -LLL -H ldaps://172.17.0.2 -s base -b 'dc=edt,dc=org' --> Comprovem 'startls' i ara si que va perquè tenim el certificat (CA)

ldapsearch -x -LLL -ZZ -h 172.17.0.2 -s base -b 'dc=edt,dc=org' --> Ara també ens funciona amb el -ZZ

sudo vim /etc/hosts

```
172.X.X.X		ldap.edt.org myldap mysecureldapserver.org
```

ldapsearch -x -LLL -ZZ -h ldap.edt.org -s base -b 'dc=edt,dc=org' --> Tràfic segur (FQDN correcte, igual que el certificat del servidor)

ldapsearch -x -d1 -LLL -ZZ -h myldap -s base -b 'dc=edt,dc=org' --> L'URI autoritzat no és aquest (FQDN), és 'ldap.edt.org' en el certificat del servidor --> SI li treiem la 'ZZ' ens deixarà, però tràfic NO SEGUR

## DINS DEL CONTAINER

dnf install openssl -y

openssl x509 -noout -text -in servercert.ldap.pem --> Veiem contingut del certificat del servidor

openssl s_client -connect gmail.com:443 < /dev/null 2> /dev/null | openssl x509 -noout -text --> Vomita la informació com si fos un 'telnet'
