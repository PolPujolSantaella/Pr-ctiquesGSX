#!/bin/bash

#Configurar el entorn de la empresa
mkdir -p /empresa
mkdir -p /empresa/bin

#1: Sticky Bit (Nms Propietari pot eliminar arxius)
#7: Propietari (L/E/W)
#5: Grup (L/E)
#5: Altres usuaris (L/E)
chmod 1755 /empresa/bin

#Modificació fitxer configuració .bashrc
echo 'export PATH="$PATH:/empresa/bin"' >> /etc/skel/.bashrc
echo 'mkdir -p $HOME/bin' >> /etc/skel/.bashrc

echo "Entorn configurat!"
