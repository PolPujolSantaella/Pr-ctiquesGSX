#!/bin/bash

#Verificar el número correcte d'arguments
if [ "$#" -ne 1 ]; then
    echo "Ús: $0 <IP_remota>"
    exit 1
fi

ip_remota=$1

DNI="39939378"
IND=$(echo $DNI | tr -cd [:digit:] | rev)

user="gsxViewer"

echo "Realitzant proves SNMP en $ip_remota..."
echo "Usuari: gsxViewer"

echo "--------------------------------------------------------"
echo "Consultant la taula system:"
snmpwalk -v3 -u $user -l noauth -a SHA -A aut$IND $ip_remota system

echo "--------------------------------------------------------"
echo "Consultant la taula hrSystem:"
snmpwalk -v3 -u $user -l noauth -a SHA -A aut$IND $ip_remota hrSystem
echo "--------------------------------------------------------"

echo "Acces als MIBs de la Universitat de California, Davis:"
echo "Consultant la taula prTable:"
snmptable -v3 -u $user -l noauth -a SHA -A aut$IND $ip_remota UCD-SNMP-MIB::prTable
echo "--------------------------------------------------------"

echo "Consultant la taula dskTable:"
snmptable -v3 -u $user -l noauth -a SHA -A aut$IND $ip_remota ucdavis.dskTable
echo "--------------------------------------------------------"

echo "Consultant la taula laTable:"
snmptable -v3 -u $user -l noauth -a SHA -A aut$IND $ip_remota ucdavis.laTable
echo "--------------------------------------------------------"


user2="gsxAdmin"
echo "Usuari: $user2"
echo "--------------------------------------------------------"

echo "Consultant la taula system:"
snmpwalk -v3 -u $user2 -l noauth -a SHA -A aut$IND -x DES -X sec$IND $ip_remota system
echo "--------------------------------------------------------"

echo "Consultant la taula hrSystem:"
snmpwalk -v3 -u $user2 -l noauth -a SHA -A aut$IND -x DES -X sec$IND $ip_remota hrSystem
echo "--------------------------------------------------------"

echo "Acces als MIBs de la Universitat de California, Davis:"
echo "Consultant la taula prTable:"
snmptable -v3 -u $user2 -l noauth -a SHA -A aut$IND -x DES -X sec$IND $ip_remota UCD-SNMP-MIB::prTable
echo "--------------------------------------------------------"

echo "Consultant la taula dskTable:"
snmptable -v3 -u $user2 -l noauth -a SHA -A aut$IND -x DES -X sec$IND $ip_remota ucdavis.dskTable
echo "--------------------------------------------------------"

echo "Consultant la taula laTable:"
snmptable -v3 -u $user2 -l noauth -a SHA -A aut$IND -x DES -X sec$IND $ip_remota ucdavis.laTable
echo "--------------------------------------------------------"




exit 0
