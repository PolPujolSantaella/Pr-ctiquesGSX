#!/bin/bash

############
# PART 3.1 #
############

#Script Router

#A) Assignar amb iproute2 la primera IP disponible

ip address add 198.18.112.1/20 broadcast 192.18.127.255 dev eth1
ip link set eth1 up

# Assignar configuració de la eth2
ip address add 172.24.0.1/17 broadcast 172.24.127.255 dev eth2
ip link set eth2 up


#B) Activar IPv4 forwarding de forma permanent

if ! grep -q "net.ipv4.ip_forward=1" /etc/sysctl.conf; then
    echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
    sysctl -p
fi

#C) Posar noms a /etc/hosts

#Comprovar si ja existeix la entrada en /etc/hosts abans de agregar-la
#if ! grep -q "198.18.127.254 server" /etc/hosts; then
#    echo "198.18.127.254 server" >> /etc/hosts
#fi

#if ! grep -q "10.0.2.16 casa" /etc/hosts; then
#    echo "10.0.2.16 casa" >> /etc/hosts
#fi

#D) Configurar SNAT per sortida a Internet
if ! iptables -t nat -C POSTROUTING -s 198.18.112.0/20 -o eth0 -j MASQUERADE; then
    iptables -t nat -A POSTROUTING -s 198.18.112.0/20 -o eth0 -j MASQUERADE
fi

# Configuració SNAT per a la xarxa intranet
if ! iptables -t nat -C POSTROUTING -s 172.24.0.0/17 -o eth0 -j MASQUERADE; then
    iptables -t nat -A POSTROUTING -s 172.24.0.0/17 -o eth0 -j MASQUERADE
fi

# Redirecció consultes DNS cap a un servidor extern
iptables -t nat -A PREROUTING -i eth2 -d 172.24.0.1 -p udp --dport 53 -j DNAT --to-destination 8.8.8.8:53

iptables -t nat -A PREROUTING -i eth1 -d 198.18.112.1 -p udp --dport 53 -j DNAT --to-destination 8.8.8.8:53

iptables -t nat -A PREROUTING -i eth2 -d 172.24.0.1 -p tcp --dport 53 -j DNAT --to-destination 8.8.8.8:53

iptables -t nat -A PREROUTING -i eth1 -d 198.18.112.1 -p tcp --dport 53 -j DNAT --to-destination 8.8.8.8:53


#E) Servei SSH i Permetre Accés remot usuari root

grep ssh /etc/services
ss -4ltn
dpkg -s openssh-server > /dev/null 2>&1

#Mirem si està instal·lat
if [ $? -ne 0 ]; then
    echo "El servei SSH no està instal·lat. Instalant..."
    apt install -y openssh-server
fi

#systemctl status ssh

if [ $? -eq 0 ]; then
    echo "El servei SSH està actiu"
else
    echo "El servei SSH no està actiu. Inicialitzant..."
    systemctl start ssh
fi

sed -i 's/^#PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config

systemctl restart ssh

############
# PART 3.2 #
############

#Configurar client dhcp
if ! grep -q "prepend domain-name-servers 198.18.127.254;" /etc/dhcp/dhclient.conf; then
    echo "prepend domain-name-servers 198.18.127.254;" | tee -a /etc/dhcp/dhclient.conf > /dev/null
fi
if ! grep -q "supersede domain-search \"intranet.gsx\";" /etc/dhcp/dhclient.conf; then
    echo "supersede domain-search \"intranet.gsx\";" | tee -a /etc/dhcp/dhclient.conf > /dev/null
fi

if ! grep -q "supersede domain-name \"intranet.gsx\";" /etc/dhcp/dhclient.conf; then
    echo "supersede domain-name \"intranet.gsx\";" | tee -a /etc/dhcp/dhclient.conf > /dev/null
fi

#Permetre tràfic DNS sortint desde els contenedors fins servidor DNS
iptables -A FORWARD -p udp --dport 53 ! -d 198.18.127.254 ! -s 198.18.127.254 -j DROP
iptables -A FORWARD -p tcp --dport 53 ! -d 198.18.127.254 ! -s 198.18.127.254 -j DROP

#Descartar totes les consultes DNS sortint cap a Internet que no provinguin del servidor DNS
iptables -t nat -A PREROUTING -i eth0 -p udp --dport 53 -j DNAT --to-destination 198.18.127.254:53
iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 53 -j DNAT --to-destination 198.18.127.254:53

echo "Configuració completada."
