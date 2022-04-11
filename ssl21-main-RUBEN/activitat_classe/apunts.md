# tls21

SSL --> Abans
TLS --> Ara --> Seguritat de la capa de transprot
http**s**, smtp**s**, ldap**s**

Client ------Túnel-----> Servidor Web (port 443 --> Certificat digital)

El client quan és connecta detectarà que al 'Servidor Web', hi ha un certificat digital.

Certficiats digitals poden ser de moltes coses --> de notes, de dimonis, de servidor (aquest serveix per abalar que el servidor és qui diu ser), de client (per abalar que el client és qui diu ser)

Clau privada (genera...) --> Clau pública (aquesta fara un request que conté la clau pública i ID del Subject (sujeto)) --> Quan arriba al CA i la certifiquen, aquest certificat conté --> Clau pública, ID: Dades identificatives, Subject, Identitat issuer (el que emet (fà) el certificat), firma

Identitat issuer i firma --> Signats per la clau privada del issuer (entitat de certificació)

Infraestructura anomenada: PKI (Publick Key Infraestructure)

CA (Certification Authorities) --> Poden haver-hi CA delegades (podem tirar cap a sota)

No hi ha inconvenients en fer un nou certificat (estaràn dins d'aquest certificat tothom que vulgui estar dins) --> Qüestió de confiança

Per poder tenir un certificat hem d'anar a la Autoritat de Certificació i comprar-ho --> Depen del que vulguis costarà més o menys

Resum: Certificat dígital = Clau pública + ID subject + ID de qui ho firma (issuer) + firma

## Exemples (Activitat clase):
Usuari (pere) és crea una clau privada i clau pública --> Request (petició que enviarà a...) --> CA, aquesta verifica que l'usuari és qui diu ser --> Fabricarà el certificat que enviarà a l'usuari)

genrsa --> Tipus de clau privada (Els principals: RSA)
in --> Request

## Explicació navegador amb certificats:
navegador --connecta--> m06.edt.org (conté un certificat autosignat: m06.edt.org)

Quan el navegador és connecti, es descarregarà el certificat però li sortirà unes preguntes (primer descarregar per analitzar)

Quan es descarrega un certificat pot quedar com a 'Servidor' o 'Entitat'

Un cop descarregat, la propera vegada que el navegador es connecti ja no li dirà res ja que ja ho té registrat

Si ens connectem a m11.edt.org (un altra web amb un certificat autosignat: m11.edt.org), ens tornarà a generar un altra exepció de seguretat

Haurem d'acceptar el certificat i que ens quedi emmagaztemat

Que passaría si aquests m11/06.edt.org, tinguesin el seu CA amb veritat?

Ens surt l'expeció de seguretat perquè ens estem descarregant el CA de servidor i no d'entitat

VOLEM EMMAGATZEMAR EL DE L'ENTITAT!

## Repàs:
TOT EL TEMA DE CERTIFICATS VA SEMPRE ASSOCIAT AMB EL 'FQDN'! (DNS!!!!!)

openssl.conf --> FITXER DE CONFIGURACIÓ

## Teoría LDAP:
client --connecta via text plà--> ldap.edt.org

Quan el client és connecta per text plà a 'ldap.edt.org' al port 636, ho fa vía TLS (antigament SSL) --> tràfic segur (xifrat)

ldapsearch -x -Z ... --> -Z = si pot, que utilitzi ldap**s**
ldapsearch -x -ZZ ... --> -ZZ = utilitza ldap**s** SÍ O SÍ, si no, no et connectes

Existeix per quan el client es connecte via text plà, utilitzi **STARTTLS**, tant client com servidor han de tenir la capacitat de fer aquest dialeg (STARTTLS), és un dialeg per qual client i servidor parlen per el port desprotegit i acorden parlar de manera protegida (acabaran parlant per un tràfic TLS), llavors el tràfic és farà per un port NO SEGUR, però el tràfic SÍ QUE SERÀ SEGUR.

