#!/bin/bash

#Verificar arguments
if [ $# -ne 2 ]; then
    echo "Ús: $0 <fitxer_usuaris> <fitxer_projectes>"
    exit 1
fi

#Directoris base si no existeixen els creem
usuaris_dir="/empresa/usuaris"
projectes_dir="/empresa/projectes"

for dir in "$usuaris_dir" "$projectes_dir"; do
    if [ ! -d "$dir" ]; then
        echo "Directori base $usuaris_dir no existeix. Creant Directori..."
        mkdir -p "$dir"
        #7: Propietari (L/E/W)
        #5: Grup (L/E)
        #5: Altres usuaris (L/E)
        chmod 755 "$dir"
    fi
done

#Procesar arxiu de usuaris
line=0
while IFS=":" read -r dni nom_complet telefon projectes; do
    #Saltem la línea de descripció
    ((line++))
    if [ "$line" -eq 1 ]; then
        continue
    fi

    cognoms=$(echo "$nom_complet" | cut -d',' -f1)
    nom=$(echo "$nom_complet" | cut -d',' -f2 | sed 's/ //g')
    inicial1=$(echo "${cognoms:0:1}" | tr '[:lower:]' '[:upper:]')
    inicial2=$(echo "${cognoms##* }" | cut -c1)
    echo "$inicial1_s $inicial2_s"

    login="$nom$inicial1$inicial2"

    #Si el login està repetit fiquem count al davant i anem incrementant
    count=0
    while [ -d "$usuaris_dir/$login" ]; do
        ((count++))
        login="$nom$inicial1$inicial2$count"
    done

    #Creem usuari
    echo "Creant usuari $login..."
    useradd -m -d "$usuaris_dir/$login" -s /bin/bash "$login"

    if [ $? -ne 0 ]; then
        echo "Error al crear usuari: $login"
    else
        echo "Usuari creat: $login!"
    fi
    #Fiquem de contrasenya el seu dni i fiquem el dni al comentari
    echo "$login:$dni" | chpasswd
    usermod -c "$dni" "$login"

    #Per cada projecte creem un grup i fiquem l'usuari dins del grup
    IFS=',' read -r -a projectes_array <<< "$projectes"
    for projecte in "${projectes_array[@]}"; do
        groupadd -f "$projecte"
        usermod -a -G "$projecte" "$login"
    done

done < "$1"


#Processar arxiu de projectes
line1=0
while IFS=":" read -r nom_projecte dni descripcio; do
    #Saltem la primera linea de descripció
    ((line1++))
    if [ "$line1" -eq 1 ]; then
        continue
    fi
    # Creem directori del projecte
    mkdir -p "$projectes_dir/$nom_projecte"
    #Mirem si quin nom Correspon dni
    cap=$(grep -E ":[^:]*:$dni" /etc/passwd | cut -d: -f1)
    #Posem com a propietari el cap i grup nom_projecte
    chown "$cap":"$nom_projecte" "$projectes_dir/$nom_projecte"
    #1: Sticky bit (Nms el propietari pot eliminar)
    #7: Propietari (L/E/W)
    #7: Grup (L/W/E)
    #0: Altres usuraris ()
    chmod 1770 "$projectes_dir/$nom_projecte"
    umask 0002 #Fitxers de dins tindran permisos de lectura i escriptura

    echo "Projecte $nom_projecte creat i configurat! Cap del Projecte: $cap"

done < "$2"

echo "Alta Usuaris completada"
