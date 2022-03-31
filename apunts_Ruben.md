# ssl21

SSL --> Abans
TLS --> Ara --> Seguritat de la capa de transprot
http**s**, smtp**s**, ldap**s**

Client ------Túnel-----> Servidor Web (port 443 --> Certificat digital)

El client quan és connecta detectarà que al 'Servidor Web', hi ha un certificat digital.

Certficiats digitals poden ser de moltes coses --> de notes, de dimonis, de servidor (aquest serveix per abalar que el servidor és qui diu ser), de client (per abalar que el client és qui diu ser)

Clau privada | Clau pública (aquesta tindrà un certificat --> contindrà --> Clau pública, ID: Dades identificatives, Subject, Identitat issuer (el que emet (fà) el certificat), firma)

Identitat issuer i firma --> Signats per la clau privada del issuer (entitat de certificació)

Infraestructura anomenada: PKI (Publick Key Infraestructure)

CA (Certification Authorities) --> Poden haver-hi CA delegades (podem tirar cap a sota)

No hi ha inconvenients en fer un nou certificat (estaràn dins d'aquest certificat tothom que vulgui estar dins) --> Qüestió de confiança

Per poder tenir un certificat hem d'anar a la Autoritat de Certificació i comprar-ho --> Depen del que vulguis costarà més o menys

Resum: Certificat dígital = Clau pública + ID subject + ID de qui ho firma (issuer) + firma

## Exemples (Activitat clase):
Usuari (pere) és crea una clau privada i clau pública --> Request (petició que enviarà a...) --> CA, aquesta verifica que l'usuari és qui diu ser --> Fabricarà el certificat que enviarà a l'usuari)

genrsa --> Tipus de clau privada (Els principals: RSA)
