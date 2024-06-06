#!/bin/bash

#Script Router

#A) Assignar amb iproute2 la primera IP disponible

ip address add 198.18.112.1/20 broadcast 192.18.127.255 dev eth1

ip link set eht1 up

#B) Activar IPv4 forwarding de forma permanent

echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
sysctl -p

#C) Posar noms a /etc/hosts

#Comprovar si ja existeix la entrada en /etc/hosts abans de agregar-la
if ! grep -q "198.18.127.254 server" /etc/hosts; then
    echo "198.18.127.254 server" >> /etc/hosts
fi

if ! grep -q "10.0.2.16 casa" /etc/hosts; then
    echo "10.0.2.16 casa" >> /etc/hosts 
fi

#D) Configurar SNAT per sortida a Internet

if ! iptables -t nat -C POSTROUTING -s 198.18.112.0/20 -o eth0 -j MASQUERADE; then
    iptables -t nat -A POSTROUTING -s 198.18.112.0/20 -o eth0 -j MASQUERADE
fi

#E) Servei SSH i Permetre Accés remot usuari root

grep ssh /etc/services
ss -4ltn 
dpkg -s openssh-server > /dev/null 2>&1

#Mirem si està instal·lat
if [ $? -ne 0 ]; then 
    echo "El servei SSH no està instal·lat. Instalant..."
    sudo apt install -y openssh-server
fi

sudo systemctl status ssh

if [ $? -eq 0 ]; then 
    echo "El servei SSH està actiu"
else
    echo "El servei SSH no està actiu. Inicialitzant..."
    systemctl start ssh
fi

sed -i 's/^#PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config

systemctl restart ssh

echo "Configuració completada."

