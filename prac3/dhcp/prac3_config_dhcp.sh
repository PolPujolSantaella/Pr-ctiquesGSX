#!/bin/bash

############
# PART 3.1 #
############

# Configurar la interfaz eht0
cat <<EOF > /etc/network/interfaces
auto eth0
iface eth0 inet static
    address 172.24.127.254
    network 172.24.0.0
    netmask 255.255.128.0
    gateway 172.24.0.1
    hostname $HOSTNAME
EOF

ifdown eth0 && ifup eth0

# Afegir temporalment com a nameserver la IP del router
#echo "nameserver 172.24.0.1" > /etc/resolv.conf

# Verificar si isc-dhcp-server està instal·lat
if ! dpkg -l | grep -q "isc-dhcp-server"; then
    echo "El paquet isc-dhcp-server no està instal·lat. Instal·lant...."
    apt-get update
    apt-get install isc-dhcp-server -y
    if dpkg -l | grep -q "isc-dhcp-server"; then
        echo "El paquet s'ha instal·lat"
    else
        echo "Error: No s'ha pogut instal·lar"
    fi
else
    echo "El paquet isc-dhcp-server ja està instal·lat."
fi

# Configurar isc-dhcp-server per escoltar en eth0
sed -i 's/INTERFACESv4=""/INTERFACESv4="eth0"/g' /etc/default/isc-dhcp-server
systemctl restart isc-dhcp-server

# Configurar /etc/dhcp/dhcpd.conf
cat <<EOF > /etc/dhcp/dhcpd.conf
subnet 172.24.0.0 netmask 255.255.128.0 {
    range 172.24.0.2 172.24.127.253;
    default-lease-time 7200;
    max-lease-time 28800;
    option routers 172.24.0.1;
    option domain-name "intranet.gsx";
    option domain-search "intranet.gsx";
    option domain-name-servers 198.18.127.254;
}
EOF

sed -i 's/^#PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config

systemctl restart ssh

############
# PART 3.2 #
############

#Modifica /etc/resolv.conf posant com a nameserver el server i el search dels dominis
if ! grep -q "nameserver 198.18.127.254" /etc/resolv.conf; then
    echo "nameserver 198.18.127.254" >> /etc/resolv.conf
fi

if ! grep -q "search intranet.gsx dmz.gsx" /etc/resolv.conf; then
    echo "search intranet.gsx dmz.gsx" >> /etc/resolv.conf
fi

############
# PART 3.3 #
############

#Configuració DHCPD.conf
cat <<EOF > /etc/dhcp/dhcpd.conf
key CLAU_DHCPDNS {
        algorithm hmac-md5;
        secret "ov8dcY0IcysuDtomNGcm/w==";
}

zone intranet.gsx {
    primary 198.18.127.254;
    key CLAU_DHCPDNS;
}
zone 24.172.in-addr.arpa {
    primary 198.18.127.254;
    key CLAU_DHCPDNS;
}

ddns-update-style interim;
ddns-updates on;
deny client-updates;


subnet 172.24.0.0 netmask 255.255.128.0 {
    range 172.24.0.2 172.24.127.253;
    default-lease-time 7200;
    max-lease-time 28800;
    option routers 172.24.0.1;
    option domain-name "intranet.gsx";
    option domain-search "intranet.gsx";
    option domain-name-servers 198.18.127.254;

    ddns-hostname= pick(option fqdn.hostname, option host-name,
        concat ("prefix-",binary-to-ascii(10,8,"-",
        substring(leased-address,3,1))));
    option host-name = config-option server.ddns-hostname;
}
EOF
systemctl restart isc-dhcp-server
echo "Configuració completada."
