#!/bin/bash

#Obtenir el nom de l'amfitrió
HOSTNAME=$(hostname)

echo "Configurant Servidor Syslog central al contenidor $HOSTNAME..."

#Modificar /etc/rsyslog.conf
sed -i 's/#module(load="imudp")/module(load="imudp")/' /etc/rsyslog.conf
sed -i 's/#input(type="imudp" port="514")/input(type="imudp" port="514")/' /etc/rsyslog.conf

#Afegir fitxer /etc/rsyslog.d/10-remot.conf
echo '$template GuardaRemots, "/var/log/remots/%HOSTNAME%/%timegenerated:1:10:date-rfc3339%"' > /etc/rsyslog.d/10-remot.conf
echo ':source, !isequal, "localhost" -?GuardaRemots' >> /etc/rsyslog.d/10-remot.conf

#Re-engeguem el servei i comprovem si està escoltant port 514
service rsyslog restart
ss -tuln | grep 514

#Afegir fitxer /etc/rsyslog.d/90-remot.conf
echo 'user.* @172.18.0.3:514' > /etc/rsyslog.d/90-remot.conf

service rsyslog restart
