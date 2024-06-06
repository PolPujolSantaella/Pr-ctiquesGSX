#!/bin/bash

############
# PART 3.1 #
############

# Script per als clients

host_name=$HOSTNAME
# Configuració al fitxer /etc/dhcp/dhclient.conf envia host-name i demana lease-time 1d
cat <<EOF > /etc/dhcp/dhclient.conf
#send host-name "$host_name";
request domain-name, domain-search, domain-name-servers, default-lease-time 86400;
EOF

# Aixecar interfaz eth0
ip link set dev eth0 up

systemctl restart networking

# Verificar la configuracio de red assignada
echo "Configuració de red assignada a eth0:"
ip addr show eth0
echo ""

# Gateway per defecte
echo "Gateway per defecte:"
ip route show default
echo ""

# Servidore de nom (DNS):"
cat /etc/resolv.conf
echo ""

#Comprovació del lloguer obtingut a var/lib/dhcp
echo "Registres de lloguer DHCP:"
cat /var/lib/dhcp/dhclient.eth0.leases

systemctl restart ssh

############
# PART 3.2 #
############

#Assegurar domain-name i domain-name-servers
if ! grep -q "request.*domain-name.*domain-name-servers" /etc/dhcp/dhclient.conf; then
    echo "require domain-name, domain-name-servers" | tee -a  /etc/dhcp/dhclient.conf
fi

############
# PART 3.3 #
############
cp actualitza_nom_local /etc/dhcp/dhclient-exit-hooks.d/



echo "Configuració de client DHCP completada."
