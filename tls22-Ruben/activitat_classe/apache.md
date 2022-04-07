docker run --rm --name web.edt.org -h web.edt.org --net 2hisix -d edtasixm11/tls18:https

docker exec -it web.edt.org /bin/bash

ps ax --> Comprovem que 'apache' estigui funcionant

nmap localhost

httpd -S --> Comprovem correcte funcionament (ens fixem en les rutes de configuració) / <ip_docker> --> Navegador

vim /etc/httpd/conf.d/webs.conf

cd /var/www/certs/ --> Claus privades, certificats ...

https://172.19.0.2/ --> Acceptem certificat

172.19.0.2      web.edt.org web www.auto2.cat www.auto1.cat www.web1.org www.web2.org (/etc/hosts --> docker i nostre ordinador)

ping (nostre PC) --> comprovem que tot funciona correctament

httpd -S (docker) --> comprovem que tot funciona correctament

kill -1 <PID_apache> --> hem de reiniciar per a què ens demani el certificat correcte

Quan acceptem el certificat de web1 i entrem a web2, ens ho torna a demanar perquè hem acceptat el certificat de servidor!

Ens fiquem als certificats de 'Firefox' (settings --> privacy & security --> view certificates --> authorities --> import

Importem el certificat d'entitat al nostre ordinador:

docker cp web.edt.org:/opt/docker/cacert.pem /tmp/cacert.pem
