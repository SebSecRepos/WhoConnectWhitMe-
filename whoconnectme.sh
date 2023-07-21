#!/bin/bash

greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"


if [ "$(whoami)" != "root" ]; then
    echo -e "\n${redColour}[!] Are you root?${endColour}\n"
    exit 1
fi
locate "/usr/bin/batcat" &>/dev/null 
if [ $? -ne 0 ]; then
    echo -e "\n${yellowColour}[!] Debe instalar batcat o bat ${endColour}\n" 
    exit 1
fi
locate "/usr/bin/whois" &>/dev/null 
if [ $? -ne 0 ]; then
    echo -e "\n${yellowColour}[!] Debe instalar whois ${endColour}\n" 
    exit 1
fi

function ctrl_c(){
	
   echo -e "\n${redColour}[!] Saliendo${redColour}\n"
   tput cnorm; exit 1

}

trap ctrl_c INT



openPortsList=$(netstat -nat | tr ":" " " | grep -vE 'and|Address|\*')

tput civis
echo -e "\n${greenColour}[+] Cargando..\n${endColour}"
(echo -e "$openPortsList"| while read -r line; do 

    port1=$(echo $line | awk '{print $5}')
    port2=$(echo $line | awk '{print $7}')
    connectionInfo=$(lsof -i:$port1 ) && basecommand=$(echo  "$connectionInfo" | grep -v 'COMMAND')
    connectionState=$(echo $openPortsList | awk '{print $8}')
    if [ $? -eq 0 ]; then
        pid=$( echo  $basecommand | awk '{print $2}')
        user=$( echo  $basecommand | awk '{print $3}')
        IPV=$( echo  $basecommand | awk '{print $5}')
        device=$( echo  $basecommand | awk '{print $6}')
        connecttype=$( echo  $basecommand | awk '{print $8}')
        direction=$( echo  $basecommand | awk '{print $9}')
        ip=$( echo -e  $direction | tr ":" " " | awk '{print $1}')
        remote=$( netstat -tunap | grep $port1 | awk '{print $5}' )
        ipremote=$(echo $remote | cut -d ":" -f1 )
        program=$(which $(ps -p $pid -o cmd | grep -v CMD | awk '{print $1}'))
	
        echo -e "\n[------------------------------- [ Información de conexión ] -------------------------------\n"
        echo -e "\tPrograma: \t\t $program"
        echo -e "\tPID: \t\t\t $pid"
        echo -e "\tUsuario: \t\t $user"
        echo -e "\tDispositivo: \t $device"
        echo -e "\tIPVersion: \t\t $IPV"
        echo -e "\tConexión: \t\t  $connecttype"
        echo -e "\tIp local: \t\t $ip"
        echo -e "\tIp remota:\t\t $ipremote"
        echo -e "\tPuertos: \t\t $port1/$port2"
        echo -e "\tEstado: \t\t $connectionState"

        echo -e "\n [+] Información de equipo remoto                                       \n"
        whois $ipremote | grep -E -i 'address|phone|email|e-mail|nserver|responsible|owner|OrgNOC|OrgName|Country|City|StateProv|PostalCode' | while read -r linea; do
            echo -e "\t$linea"
        done

        echo -e "-----------------------------------------------------------------------------------------------]"
        echo -e "\n"
    else
        echo ""
    fi
done) > ./file.tmp

tput cnorm
/usr/bin/batcat -l python ./file.tmp 
