#!/bin/bash

# Path absolut: /home/milax/Escriptori/GSX/P2/script_consulta.sh
# Permisos: 755 (rwxr-xr-x)
# Propietari: milax
# Grup: milax


if [ -f "/tmp/paquets" ]; then
    ./home/milax/Escriptori/GSX/P2/consulta.sh $(cat /tmp/paquets) >/home/milax/Escriptori/GSX/P2/jocProves_SYSD
else
    logger -t consultaSYSV "No s'ha trobat cap fitxer /tmp/paquets"
fi

