#!/bin/bash


echo "Proves amb router R2" | tee -a sortida_prac7.txt
echo "---------------------" | tee -a sortida_prac7.txt
docker exec R2 ip -c route | tee -a sortida_prac7.txt
echo "-----------------------" | tee -a sortida_prac7.txt
docker exec -ti R2 vtysh | tee -a sortida_prac7.txt
echo "-----------------------" | tee -a sortida_prac7.txt
docker exec R1 traceroute -n 10.112.2.2 | tee -a sortida_prac7.txt
docker exec R2 traceroute -n -T 10.112.3.2 | tee -a sortida_prac7.txt

echo "------------------------" | tee -a sortida_prac7.txt
echo "Ruta de R1 -> 10.112.2.1 abans d'abaixar" | tee -a sortida_prac7.txt
docker exec R1 ip route get 10.112.2.1 | tee -a sortida_prac7.txt
docker exec R1 traceroute -n 10.112.2.1 | tee -a sortida_prac7.txt

echo "Baixem link1_veth2..." | tee -a sortida_prac7.txt
docker exec R2 ip link set dev link1_veth2 down | tee -a sortida_prac7.txt

sleep 5

echo "Ruta R1 -> 10.112.2.1 actualitzada: " | tee -a sortida_prac7.txt
docker exec R1 ip route get 10.112.2.1 | tee -a sortida_prac7.txt
docker exec R1 traceroute -n 10.112.2.1 | tee -a sortida_prac7.txt
echo "-------------------------" | tee -a sortida_prac7.txt

