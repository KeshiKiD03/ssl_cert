# LDAP Server
## @edt ASIX M06-ASO 2021-2022
### Servidor LDAP (Debian 11)

Podeu trobar les imatges docker al Dockehub de [edtasixm06](https://hub.docker.com/u/edtasixm06/)

Podeu trobar la documentació del mòdul a [ASIX-M06](https://sites.google.com/site/asixm06edt/)

ASIX M06-ASO Escola del treball de barcelona

* **keshikid03/ldap21:group** Servidor LDAP amb la base de dades edt.org
 S'ha fet el següent:
 * Modificar el fitxer edt.org.ldif per afegir una ou grups.
 * S'han definit els següents grups:
   alumnes(600), professors(601), 1asix(610), 2asix(611), wheel(10),
   1wiam(612), 2wiam(613), 1hiaw(614).
```
docker network create 2hisx
docker build -t keshikid03/ldap21:group .
docker run --rm --name ldap.edt.org -h ldap.edt.org --net 2hisx -p 389:389 -d keshikid03/ldap21:group 

docker run --rm --name phpldapadmin.edt.org -h phpldapadmin.edt.org --net 2hisx -p 80:80 -d edtasixm06/phpldapadmin:20
```
 

