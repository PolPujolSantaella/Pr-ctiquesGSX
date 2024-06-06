#!/bin/bash

# Funció per obtenir info processos

get_process_info() {
    local pid=$1
    local cgroup=$2

    echo "Cgroup: $cgroup amb PID: $pid"
    echo "PID    PPID    Comanda"
    echo "----------------------"
    ps -e -o pid,ppid,cmd | awk -v pid="$pid" '$2 == pid' | while read -r line; do
        echo "$line"
    done

    echo ""
}

get_parent_processes() {
    local pid=$1
    local cgroup=$2

    local parent_pid=$(ps -o ppid= -p $pid)

    if [ "$parent_pid" -eq 1 ]; then
        echo "Aquest es el primer proces generat en el cgroup."
    else
    	get_process_info "$parent_pid" "$cgroup"

    	get_parent_processes "$parent_pid" "$cgroup"
    fi
}

pid=$$

cgroup=$(awk -F ':' '$3 ~ /user.slice/ {print $3}' /proc/$pid/cgroup)

echo ""
echo "Informació d'AQUESTA SHELL:"
get_process_info $pid "$cgroup"

echo ""
echo "Informació dels PROCESSOS PARE"
get_process_info $PPID "$cgroup"
get_parent_processes "$PPID" "$cgroup"
