#!/bin/bash

#Text a afegir a snmpd.conf
text="cat afegir_snmpd.txt"
if ! grep -Fxq "$text" /etc/snmp/snmpd.conf; then
    cat afegir_snmpd.txt >> /etc/snmp/snmpd.conf
fi

#Modifiquem fitxer del serveri snmpd.conf

#Per rebre UDPs desde qualsevol maquina
if ! grep -q "agentaddress udp:161" /etc/snmp/snmpd.conf; then
    sed -i 's/^agentaddress  127.0.0.1/#&/' /etc/snmp/snmpd.conf && sed -i '/#agentaddress/a agentaddress udp:161' /etc/snmp/snmpd.conf
fi

#Nom i Ubicacio
sed -i 's/sysLocation.*/sysLocation Tarragona/' /etc/snmp/snmpd.conf
sed -i 's/sysContact.*/sysContact Me <pol.pujol@estudiants.urv.cat>/' /etc/snmp/snmpd.conf

#Afegim vistes que es permeten veure branques interfaces, ip, snmp, icmp i ucdavis
if ! grep -q "view vistagsx included" /etc/snmp/snmpd.conf; then
    sed -i "/#   arguments viewname/a  view vistagsx included .1.3.6.1.2.1.2.2.1.2\\
view vistagsx included .1.3.6.1.2.1.4.20.1.2\\
view vistagsx included .1.3.6.1.2.1.11.1\\
view vistagsx included .1.3.6.1.2.1.5\\
view vistagsx included .1.3.6.1.4.1.2021.9\\
    " /etc/snmp/snmpd.conf
fi

#Afegim un community string cilbup
if ! grep -q "rocommunity cilbup localhost" /etc/snmp/snmpd.conf; then
    sed -i "/^#   arguments:  community /a rocommunity cilbup localhost" /etc/snmp/snmpd.conf
fi

#Modifiquem fitxer dels clients snmp.conf
if ! grep -q "mibs +All" /etc/snmp/snmp.conf; then
    sed -i '$a\mibs +All' /etc/snmp/snmp.conf
fi

DNI="39939378"
IND=$(echo $DNI | tr -cd [:digit:] | rev)
IP="10.0.2.3"

#Creem dos usuaris
if ! grep -q "createUser gsxViewer" /etc/snmp/snmpd.conf; then
    sed -i "/^# createUser username/a createUser gsxViewer SHA authpassphrase DES aut$IND\\
createUser gsxAdmin SHA authpassphrase DES sec$IND\\
    " /etc/snmp/snmpd.conf

fi

if ! grep -q "rouser gsxViewer" /etc/snmp/snmpd.conf; then
    sed -i "/^rouser authPrivUser/a rouser gsxViewer noauth\\
rwuser gsxAdmin noauth\\
    " /etc/snmp/snmpd.conf
fi

service snmpd restart
ss -tuln


