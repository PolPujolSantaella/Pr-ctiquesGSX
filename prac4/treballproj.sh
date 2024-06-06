#!/bin/bash

#Verifica que es proporciona un nom de projecte
if [ $# -ne 1 ]; then
    echo "Ús: $0 <nom_projecte>"
    exit 1
fi

projecte_dir="/empresa/projectes/$1"

if [ ! -d "$projecte_dir" ]; then
    echo "No existeix $projecte_dir"
    exit 1
fi

#Grup actiu estat actual i directori
grup_actual=$(id -gn)
directori=$(pwd)

cd "$projecte_dir" || exit 1

echo "Direccionant a $usuari_actual al projecte $1"
echo "Ara està a: $(pwd)"

#Modifica l'entorn per tal que el fitxers tinguin permisos necessaris
umask 002

#Modifica  el grup actiu de l'usuari a la del projecte
newgrp "$1" || echo { "No s'ha canviat al grup del projecte: $1"; exit 1 }
