#!/bin/bash

# Creació imatge
docker build -t gsx:prac7 -f dockerfile_gsx_prac7 .

OPCIONS="-itd --rm --privileged --cap-add=NET_ADMIN --cap-add=SYS_ADMIN"
imatge="gsx:prac7"

num_router=4

#Iniciem R1 xarxa per defecte
docker run $OPCIONS --hostname router1 --name R1 $imatge

node=2
while [ $node -le $num_router ]; do
    docker run $OPCIONS --hostname router$node --network=none --name R$node $imatge
    node=$((node + 1))
done

sudo ./links.sh

node=1
while [ $node -le $num_router ]; do
    docker exec R$node /root/prac7_config_rip.sh
    node=$((node + 1))
done

