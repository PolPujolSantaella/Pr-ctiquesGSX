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
#if ! grep -q "198.18.112.1 router" /etc/hosts; then
#    echo "198.18.112.1 router" >> /etc/hosts
#fi


#if ! grep -q "10.0.2.16 casa" /etc/hosts; then
#    echo "10.0.2.16 casa" >> /etc/hosts
#fi

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
# PART 3.1 #
############

#Afegir a resolv.conf com a nameserver al router
if grep -q "^nameserver" /etc/resolv.conf; then
    sed -i "s/^nameserver.*/nameserver 198.18.112.1/" /etc/resolv.conf
else
    echo "nameserver 198.18.112.1" | tee -a /etc/resolv.conf >/dev/null
fi

############
# PART 3.2 #
############

#Afegir a resolv.conf com a nameserver 8.8.8.8(Google)
sed -i "s/^nameserver.*/nameserver 8.8.8.8/" /etc/resolv.conf

# Comprovació de paquets bind9, bind9-doc, dnsutils
dpkg -s bind9 > /dev/null
if [ $? -ne 0 ]; then
    echo "Paquet bind9 no instal·lat. Instal·lant..."
    apt install -y bind9
else
    echo "Paquet bind9 instal·lat."
fi

dpkg -s bind9-doc > /dev/null
if [ $? -ne 0 ]; then
    echo "Paquet bind9-doc no instal·lat. Instal·lant..."
    apt install -y bind9-doc
else
    echo "Paquet bind9-doc instal·lat."
fi

dpkg -s dnsutils > /dev/null
if [ $? -ne 0 ]; then
    echo "Paquet dnsutils no instal·lat. Instal·lant..."
    apt install -y dnsutils
else
    echo "Paquet dnsutils instal·lat."
fi

#Forwarding les consultes desconegudes cap al servidor DNS del ISP
forwarders="10.0.2.3; 8.8.8.8;"
if ! grep -q "^ *10.0.2.3" named.conf.options; then
    sed -i '/^ *forwarders *{/a \             '"$forwarders"'' named.conf.options
fi

#Paràmetres d'inici sols atenguin peticions IPv4(-4)
sed -i 's/OPTIONS=.*/OPTIONS="-u bind -4"/' /etc/default/named

#Canvi Permisos Fitxers originals
chmod --reference=/etc/bind/named.conf named.conf
chmod --reference=/etc/bind/named.conf.local named.conf.local
chmod --reference=/etc/bind/named.conf.options named.conf.options
chmod --reference=/etc/bind/named.conf.default-zones named.conf.default-zones

#Canvi Propietari fitxers originals
chown --reference=/etc/bind/named.conf named.conf
chown --reference=/etc/bind/named.conf.local named.conf.local
chown --reference=/etc/bind/named.conf.options named.conf.options
chown --reference=/etc/bind/named.conf.default-zones named.conf.default-zones

#Copiar fitxers named* a /etc/bind
cp named* /etc/bind

#Copiar fitxers zona a /var/cache/bind
cp db* /var/cache/bind
chmod 644 /var/cache/bind/*
#Engeguem el servei
systemctl restart named

# Modifiquem /etc/resolv.conf posant localhost nameserver i els search
sed -i "s/^nameserver.*/nameserver 127.0.0.1/" /etc/resolv.conf
if ! grep -q "search intranet.gsx dmz.gsx" /etc/resolv.conf; then
    echo  "search intranet.gsx dmz.gsx" | tee -a /etc/resolv.conf >/dev/null
fi

############
# PART 3.3 #
############

#Asegurar Permisos /etc/bind que puguin escriure
chmod g+w /etc/bind

#Assegurar permisos-owners de /var/log/bind/update_debug.log
mkdir -p /var/log/bind

chown bind:bind /var/log/bind
chmod 770 /var/log/bind

touch /var/log/bind/update_debug.log
chown bind:bind /var/log/bind/update_debug.log
chmod 660 /var/log/bind/update_debug.log


echo "Configuració completada."

