# NO SE SI ES POT FER AIXI AMB DOCKER (openvpn-server@server.service)!!!
```
docker build -t balenabalena/vpn21:server .

#docker run --rm --name vpn.edt.org -h vpn.edt.org --net 2hisix -p 1134:1134 -u udp://vpn.edt.org -it balenabalena/vpn21:server

docker run --rm --name vpn.edt.org -h vpn.edt.org --net 2hisix -p 1134:1134/udp -it balenabalena/vpn21:server /bin/bash
```

**NOTA:** EL PROBLEMA ES QUE DOCKER NO TE SYSTEMD !!!!

##################################################

* **Generem clau privada simple per al servidor:**
```
openssl genrsa -out serverkey.vpn.pem
```

**Amb la clau privada, signem el 'request' i generem el fitxer 'serverreq.vpn.pem':**
```
openssl req -new -key serverkey.vpn.pem -out serverreq.vpn.pem
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
Organization Name (eg, company) [Internet Widgits Pty Ltd]:edt
Organizational Unit Name (eg, section) []:vpn
Common Name (e.g. server FQDN or YOUR name) []:vpn.edt.org
Email Address []:vpn@edt.org

Please enter the following 'extra' attributes
to be sent with your certificate request
A challenge password []:jupiter
An optional company name []:vpn
```

**Com a CA, agafem el 'request' generat previament i signarem utilitzant el fitxer d'extensions de servidor:**
```
openssl x509 -CAkey ../cakey.pem -CA ../cacert.pem -req -in serverreq.vpn.pem -days 3650 -CAcreateserial -extfile ext.server.conf -out servercert.vpn.pem

Signature ok
subject=C = CA, ST = Barcelona, L = bcn, O = edt, OU = vpn, CN = vpn.edt.org, emailAddress = vpn@edt.org
Getting CA Private Key
```
**Generem el nostre propia clau DH (exigeix per a fer tunnel VPN):**

Generate Diffie-Hellman keys used for key exchange during the TLS handshake between OpenVPN server and the connecting clients.
```
openssl dhparam -out dh2048.pem 2048
```

**Copiem tot el contingut del servidor a l'AWS:**
```
sudo scp -i ~/.ssh/labsuser.pem * admin@54.221.80.230:~
```

**DINS D'AWS...**

**Copiem els arxius a la carpeta corresponent (tant claus com conf servidor):**
```
... sudo scp -i ~/.ssh/labsuser.pem * admin@52.91.90.223:/var/tmp
```

**NOTA:** Després ho movem tot a '/etc/openvpn/server'

* **Cambiem la configuració de:**
```
sudo vim /usr/lib/systemd/system/openvpn@.service
```

**NOTA:** Afeginm el que diu la practica, menys la part de servidor

**NOTA:** Ara canviem del fitxer 'server.conf' els paths i el copiem a '/etc/openvpn/server' (destacara la línea "client-to-client" necesaria per tenir visibilitat a extrems del tunnel)

* **Cambiem això:**
```
 ca /etc/openvpn/keys/ca.crt
 cert /etc/openvpn/keys/server.crt
 key /etc/openvpn/keys/server.key
 dh /etc/openvpn/keys/dh2048.pem
```

* **Per això:**
```
 ca /etc/openvpn/server/cacert.pem
 cert /etc/openvpn/server/servercert.vpn.pem
 key /etc/openvpn/server/serverkey.vpn.pem
 dh /etc/openvpn/server/dh2048.pem
```

* **Demana generar ta.key (Ho fem a /etc/openvpn/server)**
```
sudo openvpn --genkey --secret ta.key
```

* **Enjeguem el servei:**
```
sudo systemctl start openvpn-server@server.service
```

**NOTA:** Per veure errors --> 'journalctl -xe'

* **Comprobar que servei tot ok:**
```
ps -ax | grep openvpn
```

* **VEIEM COM S'HA CREAT LA INTERFICIE VIRTUAL DEL TUNEL:**
```
ip a

*3: tun0: <POINTOPOINT,MULTICAST,NOARP,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UNKNOWN group default qlen 100
    link/none
    inet 10.8.0.1 peer 10.8.0.2/32 scope global tun0
       valid_lft forever preferred_lft forever
    inet6 fe80::719f:d139:9058:cd36/64 scope link stable-privacy
       valid_lft forever preferred_lft forever*

ip address show tun0

4: tun0: <POINTOPOINT,MULTICAST,NOARP,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UNKNOWN group default qlen 100
    link/none
    inet 10.8.0.1 peer 10.8.0.2/32 scope global tun0
       valid_lft forever preferred_lft forever
    inet6 fe80::1b2f:4841:e4a6:644e/64 scope link stable-privacy
       valid_lft forever preferred_lft forever
```

**NOTA:** On veiem que  10.8.0.1, serà la IP del servidor VPN. I les demés IP podrán ser clients

* **Mirem conectivitat del Tunnel:**
```
Des de client: ping 10.8.0.1
Des de servidor: ping 10.8.0.X ( es sabra al inciar servei i poder analitzar tun0 )
```
