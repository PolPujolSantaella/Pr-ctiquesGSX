#!/bin/bash

num_router=4
i=1
while [ $i -le $num_router ]; do
    docker stop R$i
    docker rm R$i
    i=$((i+1))
done

docker rmi -f gsx:prac7

docker image ls
ip link | grep veth
echo "Neteja completada"







