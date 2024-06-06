#!/bin/bash

#Configuració
ip_router="172.18.0.2"
OID_SET_REQUEST="SNMPv2-MIB::snmpInSetRequests"
OID_GET_REQUEST="SNMPv2-MIB::snmpInGetRequests"

get_oid(){
    local oid="$1"
    snmpget -v 2c -c public $ip_router $oid | awk '{print $NF}'
}

#Valor inicial
valor_set_request=$(get_oid $OID_SET_REQUEST)
valor_get_request=$(get_oid $OID_GET_REQUEST)

sleep 300

#Valor actual de les consultes
nou_valor_set_request=$(get_oid $OID_SET_REQUEST)
nou_valor_get_request=$(get_oid $OID_GET_REQUEST)

#Increment entre consultes
increment_set_request=$((nou_valor_set_request - valor_set_request))
increment_get_request=$((nou_valor_get_request - valor_get_request))

#Comprova si l'increment supera el llindar i envia un missatge
if [ $increment_set_request -gt 5 ]; then
    logger -p user.warining -t GSX "AVIS el valor $OID_SET_REQUEST al router ha augmentat massa: $nou_valor_set_request ($increment_set_request)"
fi

if [ $increment_set_request -gt 5 ]; then
    logger -p user.warining -t GSX "AVIS: El valor del $OID_GET_REQUEST al router ha augmentat massa: $nou_valor_get_requests ($increment_get_request)"
fi
