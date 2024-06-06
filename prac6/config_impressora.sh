#!/bin/bash

#Comprovem si es tenen permisos necessaris
if [ "$EUID" -ne 0 ]; then
    echo "Si us plau, executa com a superusuari."
    exit 1
fi

#Instal·lar CUPS
if ! dpkg -s cups &> /dev/null; then
    echo "Instal·lant CUPS..."
    apt update
    apt install -y cups cups-pdf
fi

systemctl start cups
systemctl enable cups

#Nom usuari
USER=$(whoami)

#Creem carpeta DocsPDF
mkdir -p ~/DocsPDF/

#Agrega el usuari al grup lpadmin
usermod -aG lpadmin "$USER"

#########################
#Crear impresora virtual#
#########################

#Comprovem que no estigui ja creada
impresora=$(lpstat -p | grep lpVirtual)
if [ -n "$impresora" ]; then
    lpadmin -p lpVirtual -E -v "cups-pdf:/" -P /usr/share/ppd/cups-pdf/CUPS-PDF_opt.ppd
else
    echo "Impresora ja insta·lada"
fi

#Direccionem el arxiu pdf a DocsPDF
PDF_CONF="/etc/cups/cups-pdf.conf"
dir="{HOME}/DocsPDF"
sed -i "s|^Out.*|Out $"$dir"|g" "$PDF_CONF"

#Establir impresora com predetermiada
lpadmin -d lpVirtual


systemctl restart cups
lpstat -p
lpstat -o

echo "La impresora virtual ha estat configurada."

