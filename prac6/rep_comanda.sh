#!/bin/bash

#Comprovar arguments
if [ $# -lt 1 ]; then
    echo "Ús: <comanda> [usuari]"
    exit 1
fi

comanda=$1
user=$2

#Funció per obtenir llista usuaris que han executat
function llista_usuaris_comanda() {
    local comanda=$1
    echo "Usuaris que han executat "$comanda":"
    lastcomm $comanda | cut -c1-14,23-30 | sort | uniq -c
}

#Funcio per obtenir els dies que un usuari ha executat
function comprovar_usuari() {
    local comanda=$1
    local user=$2
    echo "Comprovant si usuari $user ha executat $comanda"
    lastcomm --user $user | grep -P "^\s*${comanda}\s" | awk '{print $6, $7, $8}' | sort | uniq
    if [ $? -eq 0 ]; then
       echo "L'usuari $user ha executat la comanda"
    else
        echo "L'usuari $user NO ha executat la comanda"
    fi

}

if [ -z "$user" ]; then
    llista_usuaris_comanda $comanda
else
    comprovar_usuari $comanda $user
fi

