
#!/bin/bash

#S'EXECUTA AMB SUDO
num_router=4

#Funció que crear enllaços veth i assigna als contenidors
create_veth_link() {
    node1=$1
    node2=$2

    #Crear enllaços
    ip link add link${node1}_veth1 type veth peer name link${node1}_veth2

    #Assignar enllaços
    pid1=$(docker inspect --format '{{.State.Pid}}' R$node1)
    pid2=$(docker inspect --format '{{.State.Pid}}' R$node2)

    ip link set netns $pid1 dev link${node1}_veth1
    ip link set netns $pid2 dev link${node1}_veth2

    #Assignar IPs
    nsenter -t $pid1 -n ip addr add 10.112.$node1.1/30 dev link${node1}_veth1
    nsenter -t $pid1 -n ip link set dev link${node1}_veth1 up

    nsenter -t $pid2 -n ip addr add 10.112.$node1.2/30 dev link${node1}_veth2
    nsenter -t $pid2 -n ip link set dev link${node1}_veth2 up
}

i=1
while [ $i -le $num_router ]; do
    next=$((i % num_router + 1))
    create_veth_link $i $next
    i=$((i+1))
done
