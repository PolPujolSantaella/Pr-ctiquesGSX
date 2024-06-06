#!/bin/bash

# Path absolut: /home/milax/Escriptori/GSX/P2/consulta.sh
# Permisos: 755 (rwxr-xr-x)
# Propietari: milax
# Grup: milax


#Script que consulta la versió i dependències d'un paquet

#Verificar arguments

if [ $# -eq 0 ]; then
    echo "Ús: $0 <paquet1> [<paquet2> ...]"
    exit 1
fi

for package in "$@"; do

    echo "------------------"
    echo "PACKAGE $package:"
    echo "------------------"

    if dpkg -s "$package" &> /dev/null; then 
        echo "$package està instal·lat"

	versio=$(dpkg -s "$package" | grep '^Version: ' | awk '{print $2}')
	echo "Versió: $versio"

	data=$(grep " install $package" /var/log/dpkg.log* | tail -n 1 | awk '{print $1,$2}')
	echo "Data instal·lació: $data"

	act=$(apt-cache policy "$package" | grep -w 'Candidat:' | awk '{print $2}')
	if [ "$act" != "$versio" ] && [ -n "$act" ]; then
	    echo "Hi ha actualització disponible"
	else
	    echo "No hi ha actualització disponible"
	fi

	echo "Llista Dependències: "
	apt-cache depends "$package" | grep 'Depèn: ' | awk '{print $2}'

	echo "Fichers de configuració associats: "
	dpkg -L "$package" | grep '^/etc/'

    else
	echo "$package no està instal·lat."
    fi
done
