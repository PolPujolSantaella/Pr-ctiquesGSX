#!/bin/bash

SCRIPT="/root/vigila_snmp.sh"

#Afegir entrada al crontab per executar el script cada 5 min
echo "*/5 * * * * $SCRIPT" >> /var/spool/cron/crontabs/$(whoami)

service cron reload
