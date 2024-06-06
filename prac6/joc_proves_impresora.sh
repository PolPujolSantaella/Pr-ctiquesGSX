#!/bin/bash

#Es pot enviar a imprimir amb la comanda lp?
echo "Aixo es una prova" | lp
lpstat -p
echo "Esperant a que es completi la impressió..."

sleep 10
echo "Mostrant arxius directori ~/DocsPDF"
ls -l /home/milax/DocsPDF

echo "----------------------------_"

#Es pot aturar enviament cap a l'impresora?
echo "Prova per aturar" | lp
ID=$(lpstat -o | awk 'NR==1 {print $1}')

if [ -n "$ID" ]; then
    echo "Aturant treball de impressió $ID..."
    cancel $ID
fi

r=$(lpstat -o)

if [ ! -n "$r" ]; then
    echo "S'ha dentingut correctament."
else
    echo "Hi ha documents a enviar encara"
fi

