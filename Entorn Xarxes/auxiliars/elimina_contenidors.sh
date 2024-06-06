#!/bin/sh

# Descripció:
# Eliminar (selectivament) els contenidors

# Assignatura: GSX
# Autor: Josep M Banús Alsina
# Versió: 2.1

echo "Exec: $0\n"
[ $(id -u) -ne 0 ] && echo "$0: Has de ser root" && exit 1

[ $# -eq 1 ] && interactiu=0 || interactiu=1

path=$(dirname "$(realpath "$0")")
definicions=$(find "$path" -name "definicions.sh" | head -1)
[ -z "$definicions" ] && echo "Falta el fitxer: definicions.sh" && exit 1
[ ! -f "$definicions" ] && echo "Falta +x a: definicions.sh" && exit 1
. "$definicions" >/dev/null 2>&1

fitxer=$relpath/atura_contenidors_lxc.sh
[ ! -x $fitxer ] && echoError "Falta el fitxer (executable) $fitxer" && exit 1

nnodes=0
for node in $NODES $NODEBASE
do
	creat=$(lxc-ls | grep -c $node)
	[ $creat -ne 0 ] && nnodes=1 && break
done

[ $nnodes -eq 0 ] && echo "$0: No hi ha cap contenidor lxc." && exit 0

$relpath/atura_contenidors_lxc.sh

for node in $NODES $NODEBASE
do
	creat=$(lxc-ls | grep -c $node)
	if [ $creat -ne 0 ]; then
		[ $node != $NODEBASE ] && answ='y' || answ='n'
		if [ $interactiu -eq 1 ]; then
			if [ $node = $NODEBASE ]; then
				echoAvis "El node '$NODEBASE' sols és per a clonar els altres"
				echoAvis "Serveix per agilitzar la creació dels altres."
				echoAvis "No s'executa mai. No té ni guarda cap configuració."
			fi
			read -p "Vols elimiar el node '$node' ? [N,y] " answ
			answ=${answ:-'n'}
			[ $answ = 'Y' ] && answ='y'
			if [ $node = $NODEBASE -a $answ = 'y' ]; then 
				whiptail --title "Elimant $node" --yesno \
						"Si eliminem aquest node després la regeneració tardarà força\n \
						(doncs es clona per a fer els altres nodes)\n \n \
						Estàs segur ?" \
						--defaultno 10 65
					[ $? -eq 1 ] && continue
			fi
		fi
		if [ $answ = 'y' -o $answ = 'Y' ]; then 
			echo Eliminant node $node
			lxc-stop --kill $node 2>/dev/null
			lxc-destroy $node
			[ -f /tmp/debug_$node ] && rm /tmp/debug_$node 
		fi
	fi
done

echo
exit 0
