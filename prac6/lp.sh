#!/bin/bash

#Error
mostra_error(){
    echo "Error: $1" >&2
    exit 1
}

validar_paraula(){
    paraula="$1"
    if [ "$paraula" != "siusplau" ]; then
        mostra_error "Paraula clau incorrecte"
    else
        return 0
    fi
}

echo -n "Introdueix la paraula clau: "
stty -echo
read paraula_clau
stty echo
echo

validar_paraula "$paraula_clau"

if [ $? -eq 0 ]; then
    lp $1
fi
