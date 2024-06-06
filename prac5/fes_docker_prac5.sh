#!/bin/bash

# Creació
docker build -t gsx:prac5 -f dockerfile_gsx_prac5 .

# Crear les xarxes i els contenidors pertinents
if ! docker network inspect ISP &>/dev/null; then
    docker network create --driver=bridge --subnet=10.0.2.16/24 ISP
fi

if ! docker network inspect DMZ &>/dev/null; then
    docker network create --driver=bridge --subnet=$IPSDMZ --gateway=$IP2aDMZ DMZ
fi

if ! docker network inspect INTRANET &>/dev/null; then
    docker network create --driver=bridge --subnet=$IPSINTRA --gateway=$IP2aINTRA INTRANET
fi

docker network ls
docker network inspect DMZ
docker network inspect INTRANET

# Execució
OPCIONS="-itd --rm --privileged --cap-add=NET_ADMIN --cap-add=SYS_ADMIN"
imatge="gsx:prac5"

docker run $OPCIONS --hostname router --network=ISP --name Router \
--mount type=bind,ro,src=$(pwd)/practica5,dst=/root/prac5  $imatge
docker network connect DMZ Router
docker network connect INTRANET Router
xterm -e docker attach Router &

docker run $OPCIONS --hostname server --network=DMZ --name Server \
--mount type=bind,src=$(pwd)/practica5,dst=/root/prac5  $imatge
xterm -e docker attach Server &

docker run $OPCIONS --hostname dhcp --network=INTRANET --name Dhcp \
--mount type=bind,ro,src=$(pwd)/practica5,dst=/root/prac5 $imatge
xterm -e docker attach Dhcp &

