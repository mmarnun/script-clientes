#!/bin/bash
rojo='\033[31m'
verde='\033[32m'
amarillo='\033[33m'
azul='\033[34m'
rosa='\033[35m'
cian='\033[36m'
naranja='\033[38;5;208m'
blanco='\033[37m'

normal='\033[0m'
negrita='\033[1m'

function f_principal {
    echo -e "${cian}${negrita}Funciona!"
    echo -e "${rosa}Script creado por Manuel Alejandro Martín Núñez.${normal}"
    echo -e "${rosa}Bienvenido al script de creación de máquinas virtuales."
    echo ""
    sleep 1
    echo -e "${cian}Este script te guiará a través del proceso para crear una nueva máquina virtual."
    echo ""
    sleep 4
}

function f_comprobarroot {
    if [[ $USER != "root" ]]; then
        echo -e "${rojo}${negrita}El script debe ser ejecutado como root.${normal}"
        return 1
    else
        echo -e "${verde}${negrita}El script va a ser ejecutado como usuario root!${normal}"
        echo ""
        sleep 1
        return 0
    fi
}

function f_comprobarplantilla {
    if virsh -c qemu:///system list --all | grep -q "plantilla-cliente-alex"; then
        echo -e "${verde}${negrita}La máquina virtual 'plantilla-cliente-alex' existe.${normal}"
        echo -e "${verde}Se va aproceder con la clonación."
    else
        echo -e "${rojo}${negrita}Error: La máquina virtual 'plantilla-cliente-alex' no existe.${normal}"
        echo -e "${rojo}Por favor, verifica y vuelve a ejecutar el script."
        exit 1
    fi
}

function f_datos {
    nombremaquina=$1
    espaciovol=$2
    nombre_red=$3
    
    if [[ -z "$nombremaquina" || -z "$espaciovol" || -z "$nombre_red" ]]; then
        echo -e "${rojo}${negrita}Error: Debes proporcionar el nombre de la máquina, el tamaño del volumen y el nombre de la red.${normal}"
        exit 1
    fi
}
function f_volumen {
    echo -e "${naranja}Creando volumen a partir de la plantilla..."
    sleep 2
    virsh --connect qemu:///system vol-create-as default "${nombremaquina}.qcow2" "${espaciovol}" --format qcow2 --backing-vol prueba1.qcow2 --backing-vol-format qcow2 >> /dev/null
    echo -e "${naranja}${negrita}Volumen creado con éxito!${normal}"
    echo ""
}

function f_hostname {
    echo -e "${naranja}Cambiando el hostname a la nueva maquina..."
    sleep 1
    virt-customize --connect "qemu:///system" -a "/var/lib/libvirt/images/${nombremaquina}.qcow2" --hostname "${nombremaquina}" >> /dev/null
    echo -e "${naranja}${negrita}Hostname cambiado con éxito!${normal}"
    echo ""
}

function f_redimension {
    echo -e "${naranja}Redimensionando disco de la nueva máquina..."
    sleep 2
    cp "/var/lib/libvirt/images/${nombremaquina}.qcow2" "/var/lib/libvirt/images/new${nombremaquina}.qcow2" >> /dev/null
    virt-resize --expand /dev/sda1 "/var/lib/libvirt/images/new${nombremaquina}.qcow2" "/var/lib/libvirt/images/${nombremaquina}.qcow2" >> /dev/null
    echo -e "${naranja}${negrita}Disco redimensionado con éxito!${normal}"
    echo ""
}

function f_clonacion {
    espaciovolnum=$(echo "${espaciovol}" | sed 's/G//')
    echo -e "${naranja}Creando máquina a partir de la plantilla..."
    sleep 2
    virt-install --connect qemu:///system --noautoconsole \
    --virt-type kvm \
    --name "${nombremaquina}" \
    --os-variant debian11 \
    --disk path="/var/lib/libvirt/images/${nombremaquina}.qcow2",size="${espaciovolnum}",format=qcow2 \
    --memory 4096 \
    --vcpus 2 \
    --import
    echo -e "${naranja}${negrita}Máquina creada con éxito!${normal}"
    echo ""
}


function f_conectarred {
    echo -e "${naranja}Conectando la nueva máquina en la red indicada..."
    sleep 3
    virsh -c qemu:///system attach-interface "$nombremaquina" network "$nombre_red" --model virtio --persistent >> /dev/null
    echo -e "${naranja}${negrita}Conectada con éxito!${normal}"
    echo ""
}


function f_iniciarmaquina {
    echo -e "${naranja}Iniciando la máquina..."
    sleep 2
    echo -e "${naranja}${negrita}Máquina iniciada con éxito!${normal}"
    echo ""
}

function f_finscript {
    echo -e "${rosa}${negrita}¡Script finalizado!${normal}"
    echo ""
    echo -e "${cian}El script ha creado una maquina nueva a partir de la plantilla, ha redimensionado el disco, lo ha conectado a la red y finalmente lo ha inciado.${normal}${blanco}"
}
