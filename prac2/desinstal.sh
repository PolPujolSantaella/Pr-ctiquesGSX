#!/bin/bash

# Path absolut del script: /home/milax/Escriptori/GSX/P2/desinstal.sh
# Permisos correctes: 755 (rwxr-xr-x)
# Propietari correcte: milax
# Grup correcte: milax

#Script de desinstal·lació de paquets

if [ $# -eq 0 ]; then
    echo "Ús: $0 <paquet1> [<paquet2> ...]"
    exit 1
fi

for package in "$@"; do

    if dpkg -l | grep -q "^ii.*$package "; then

        echo "------------------------"
        echo "Desinstal·lant $package"
        echo "------------------------"

        sudo apt-get remove $package

        if [ $? -eq 0 ]; then
            echo "$package desinstal·lat amb èxit."
        else
    	    echo "Error en desinstal·lar $package."
        fi
    else
        echo "$package no està instal·lat."
    fi
done

