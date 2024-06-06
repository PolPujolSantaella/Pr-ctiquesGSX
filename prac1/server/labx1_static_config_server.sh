#!/bin/bash

#Script Server

#A) Ifupdown (amb la configuració de /etc/network/interfaces) assignem la primera IP

cat <<EOF > /etc/network/interfaces
auto eth0
iface eth0 inet static
    address 198.18.127.254
    network 198.18.112.0
    netmask 255.255.240.0
    broadcast 198.18.127.255
    gateway 198.18.112.1
    hostname $HOSTNAME
EOF

ifdown eth0 && ifup eth0

#C) Posar noms a /etc/hosts

#Comprovar si ja existeix la entrada en /etc/hosts abans de agregar-la
if ! grep -q "198.18.112.1 router" /etc/hosts; then
    echo "198.18.112.1 router" >> /etc/hosts
fi

if ! grep -q "10.0.2.16 casa" /etc/hosts; then
    echo "10.0.2.16 casa" >> /etc/hosts 
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
