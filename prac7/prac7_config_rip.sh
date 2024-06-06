#!/bin/bash

#Configuració del servei zebra
cat <<EOF > /etc/quagga/zebra.conf
EOF

#Configuració del servei ripd
HOSTNAME=$(hostname)
if [ "$HOSTNAME" == "router1" ]; then
    cat <<EOF > /etc/quagga/ripd.conf
router rip
  version 2
! Reds
  network 10.112.1.0/30
  network 10.112.4.0/30
  default-information originate
  passive-interface eth0
EOF
    iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
fi

if [ "$HOSTNAME" == "router2" ]; then
    cat <<EOF > /etc/quagga/ripd.conf
router rip
  version 2
! Reds
  network 10.112.1.0/30
  network 10.112.2.0/30
EOF
fi

if [ "$HOSTNAME" == "router3" ]; then
    cat <<EOF > /etc/quagga/ripd.conf
router rip
  version 2
! Reds
  network 10.112.2.0/30
  network 10.112.3.0/30
EOF
fi

if [ "$HOSTNAME" == "router4" ]; then
    cat <<EOF > /etc/quagga/ripd.conf
router rip
  version 2
! Reds
  network 10.112.3.0/30
  network 10.112.4.0/30
EOF
fi



chown -R quagga.quaggavty /etc/quagga/
chmod 640 /etc/quagga/*conf

service zebra restart
service ripd restart

