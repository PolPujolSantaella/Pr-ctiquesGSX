#!/bin/bash

if ! dpkg -s sysstat &> /dev/null; then
    echo "Instal·lant sysstat..."
    apt update
    apt install -y sysstat
fi

if ! dpkg -s stress &> /dev/null; then
    echo "Instal·lant stress..."
    apt update
    apt install -y stress
fi

#Crear directori de logs si no existeix
mkdir -p logs

#Funció per estressar la CPU
estresar_cpu() {
    echo "Estresant CPU..."
    stress --cpu 4 --timeout 30 &
}

#Funció per estresar la memoria
estresar_memoria() {
    echo "Estresant Memoria..."
    stress --vm 2 --vm-bytes 256M --timeout 30 &
}


#Funció per estresar el disc
estresar_disc() {
    echo "Estresant Disc..."
    stress --hdd 2 --timeout 30 &
}

#Monotoritzar recursos
monitoritzar_recursos() {
    echo "Monotoritzant recursos..."
    vmstat 1 > logs/vmstat.log &
    iostat 1 > logs/iostat.log &
}

#Neteja processos de stress després de la seva execució
neteja_processos() {
    echo "Netejant processos de stress..."
    pkill -f stress
}

#Executar monitorització i estres en secuencia

monitoritzar_recursos

estresar_cpu
sleep 35

estresar_memoria
sleep 35

estresar_disc
sleep 35

neteja_processos

echo "Monotoritzacio completa. Revisa els logs"
