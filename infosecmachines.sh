#!/bin/bash

#Colours
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"

function ctrl_c(){
  echo -e "\n${redColour}[!] Saliendo...${endColour}"
  tput cnorm && exit 1
}

trap ctrl_c INT

main_url="https://docs.google.com/spreadsheets/u/0/d/1dzvaGlT_0xnT-PGO27Z_4prHgA8PHIpErmoWdlUrSoA/gviz/tq?tqx=out:pdf"

function help_panel(){
  echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Uso:${endColour}"
  echo -e "\t${purpleColour}u)${endColour} ${grayColour}Descargar o actualizar archivos necesarios${endColour}"
  echo -e "\t${purpleColour}m)${endColour} ${grayColour}Buscar por nombre de máquina${endColour}"
  echo -e "\t${purpleColour}i)${endColour} ${grayColour}Buscar por dirección IP${endColour}"
  echo -e "\t${purpleColour}o)${endColour} ${grayColour}Buscar por el sistema operativo${endColour}"
  echo -e "\t${purpleColour}d)${endColour} ${grayColour}Buscar por la dificultad de una máquina${endColour}"
  echo -e "\t${purpleColour}s)${endColour} ${grayColour}Buscar por skill${endColour}"
  echo -e "\t${purpleColour}c)${endColour} ${grayColour}Buscar por certificación${endColour}"
  echo -e "\t${purpleColour}y)${endColour} ${grayColour}Obtener link de la resolución de la máquina en YouTube${endColour}"
}

function update_files(){
  tput civis
  if [ ! -f htbmachines.json ]; then
    echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Descargando archivos necesarios...${endColour}"
    sleep 1
    curl -s -X GET "$main_url" | sed 's/\/\*O_o\*\///' | grep -v '^$' | sed 's/google.visualization.Query.setResponse(//' | sed 's/);$//' | sed 's/,"parsedNumHeaders":0//' | jq 'del(.table.rows.[0,1])' | jq '.table.rows' > htbmachines.json
    echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Todos los archivos han sido descargados...${endColour}"
  else
    echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Comprobando si hay actualizaciones pendientes...${endColour}"
    sleep 1
    curl -s -X GET "$main_url" | sed 's/\/\*O_o\*\///' | grep -v '^$' | sed 's/google.visualization.Query.setResponse(//' | sed 's/);$//' | sed 's/,"parsedNumHeaders":0//' | jq 'del(.table.rows.[0,1])' | jq '.table.rows' > htbmachines_temp.json
    md5_machines="$(md5sum htbmachines.json | awk '{print $1}')"
    md5_machines_temp="$(md5sum htbmachines_temp.json | awk '{print $1}')"
    if [ "$md5_machines" == "$md5_machines_temp" ]; then
      echo -e "\n${yellowColour}[+]${endColour} ${grayColour}No se han detectado actualizaciones, lo tienes todo al día ;)${endColour}"
      rm htbmachines_temp.json
    else
      echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Se han encontrado actualizaciones disponibles${endColour}"
      sleep 1
      rm htbmachines.json && mv htbmachines_temp.json htbmachines.json
      echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Los archivos han sido actualizados${endColour}"
    fi
  fi
  tput cnorm
}

function search_machine(){
  tput civis

  machine_name="$1"
  check_machine_name="$(jq --arg searched_machine "$machine_name" 'map(del(.[].[1,2,3,4,5,6,7])) | map(select(.[].[0].v | test("\\b\($searched_machine)\\b"; "i"))) | length' htbmachines.json)"

  if [ $check_machine_name -ne 0 ]; then

    echo -e "\n${yellowColour}[+] ${grayColour}Listando las propiedades de la máquina${endColour} ${blueColour}$machine_name${endColour}${grayColour}:${endColour}\n"
    machine="$(jq --arg searched_machine "$machine_name" 'map(del(.[].[7])) | map(select(.[].[0].v | test("\\b\($searched_machine)\\b"; "i"))) | [.[].c[]]' htbmachines.json)"
    keys=("Máquina" "Dirección IP" "Sistema Operativo" "Dificultad" "Skills" "Certificaciones" "Writeup")

    echo -e "${grayColour}${keys[0]}:${endColour} $(echo "$machine" | jq -r '.[0].v')"
    echo -e "${grayColour}${keys[1]}:${endColour} $(echo "$machine" | jq -r '.[1].v')"
    echo -e "${grayColour}${keys[2]}:${endColour} $(echo "$machine" | jq -r '.[2].v')"
    echo -e "${grayColour}${keys[3]}:${endColour} $(echo "$machine" | jq -r '.[3].v')"
    echo -e "${grayColour}${keys[4]}:${endColour}"; echo "$(echo "$machine" | jq -r '.[4].v')" | while read skill; do echo -e "  ${grayColour}-${endColour} $skill"; done
    echo -e "${grayColour}${keys[5]}:${endColour}"; echo "$(echo "$machine" | jq -r '.[5].v')" | while read cert; do echo -e "  ${grayColour}-${endColour} $cert"; done
    echo -e "${grayColour}${keys[6]}:${endColour} $(echo "$machine" | jq -r '.[6].v')"

  else
    echo -e "\n${redColour}[!] La máquina proporcionada no existe${endColour}\n"
  fi

  tput cnorm
}

function search_ip(){
  tput civis

  ip_address="$1"
  check_ip_address="$(jq --arg searched_ip "$ip_address" 'map(del(.[].[2,3,4,5,6,7])) | map(select(.[].[1].v | test("\\b\($searched_ip)\\b"; "i"))) | length' htbmachines.json)"

  if [ $check_ip_address -ne 0 ]; then
    machine_found="$(jq -r --arg searched_machine "$ip_address" 'map(del(.[].[2,3,4,5,6,7])) | map(select(.[].[1].v | test("\\b\($searched_machine)\\b"))) | .[].c.[0].v' htbmachines.json)"
    echo -e "\n${yellowColour}[+]${endColour} ${grayColour}La máquina correspondiente para la IP${endColour} ${blueColour}$ip_address${endColour} ${grayColour}es:${endColour} ${purpleColour}$machine_found${endColour}"
  else
    echo -e "\n${redColour}[!] La dirección IP proporcionada no existe${endColour}"
  fi

  tput cnorm
}

function get_os_machines(){
  tput civis

  os="$1"
  check_os="$(jq -r --arg searched_os "$os" 'map(del(.[].[1,3,4,5,6,7])) | [.[].c.[1].v] | unique | map(select(. | test("\\b\($searched_os)\\b"; "i"))) | length' htbmachines.json)"

  if [ $check_os -ne 0 ]; then
    echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Mostrando las máquinas cuyo sistema operativo es${endColour} ${blueColour}$os${endColour}${grayColour}:${endColour}\n"
    jq -r --arg searched_os "$os" 'map(del(.[].[1,3,4,5,6,7])) | map(select(.[].[1].v | test("\\b\($searched_os)\\b"; "i"))) | .[].c.[0].v' htbmachines.json | sort -u | column
  else
    echo -e "\n${redColour}[!] El sistema operativo indicado no existe${endColour}"
  fi
  tput cnorm
}

function get_machines_difficulty(){
  tput civis

  difficulty="$1"
  check_difficulty="$(jq -r --arg searched_difficulty "$difficulty" 'map(del(.[].[1,2,4,5,6,7])) | [.[].c.[1].v] | unique | map(select(. | test("\\b\($searched_difficulty)\\b"; "i"))) | length' htbmachines.json)"

  if [ $check_difficulty -ne 0 ]; then
    echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Mostrando las máquinas que poseen un nivel de dificultad${endColour} ${blueColour}$difficulty${endColour}${grayColour}:${endColour}\n"
    jq -r --arg searched_difficulty "$difficulty" 'map(del(.[].[1,2,4,5,6,7])) | map(select(.[].[1].v | test("\\b\($searched_difficulty)\\b"; "i"))) | .[].c.[0].v' htbmachines.json | sort -u | column
  else
    echo -e "\n${redColour}[!] La dificultad indicada no existe${endColour}\n"
    echo -e "${grayColour}Selecciona una de las siguientes dificultades:${endColour}\n\n ${grayColour}-${endColour} ${greenColour}Fácil${endColour}\n ${grayColour}-${endColour} ${yellowColour}Media${endColour}\n ${grayColour}-${endColour} ${purpleColour}Difícil${endColour}\n ${grayColour}-${endColour} ${redColour}Insane${endColour}"
  fi

  tput cnorm
}

function get_skill(){

  tput civis
  skill="$1"
  check_skill="$(jq --arg searched_skill "$skill" 'map(del(.[].[1,2,3,5,6,7]) | .[].[1].v |= split("\n")) | map(select(.[].[1].v[] | test("\\b\($searched_skill)\\b"; "i"))) | length' htbmachines.json)"

  if [ $check_skill -ne 0 ]; then
    echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Mostrando las máquinas donde se ve la skill${endColour} ${blueColour}$skill${endColour}${grayColour}:${endColour}\n"
    jq -r --arg searched_skill "$skill" 'map(del(.[].[1,2,3,5,6,7]) | .[].[1].v |= split("\n")) | map(select(.[].[1].v[] | test("\\b\($searched_skill)\\b"; "i"))) | unique | .[].c.[0].v' htbmachines.json | column
  else
    echo -e "\n${redColour}[!] No se ha encontrado ninguna máquina con la skill indicada${endColour}"
  fi
  tput cnorm
}

function get_cert(){
  tput civis

  cert="$1"
  check_cert="$(jq --arg searched_cert "$cert" 'map(del(.[].[1,2,3,4,6,7]) | .[].[1].v |= split("\n")) | map(select(.[].[1].v[] | test("\\b\($searched_cert)\\b"; "i"))) | length' htbmachines.json)"

  if [ $check_cert -ne 0 ]; then
    echo -e "\n${yellowColour}[+]${endColour} ${grayColour}A continuación se presentan las máquinas que te preparan para la certificación${endColour} ${blueColour}$cert${endColour}${grayColour}:${endColour}\n"
    jq -r --arg searched_cert "$cert" 'map(del(.[].[1,2,3,4,6,7]) | .[].[1].v |= split("\n")) | map(select(.[].[1].v[] | test("\\b\($searched_cert)\\b"; "i"))) | unique | .[].c.[0].v' htbmachines.json | column
  else
    echo -e "\n${redColour}[!] No se ha encontrado ninguna máquina para la certificación indicada${endColour}"
  fi

  tput cnorm
}

function get_youtube_link(){
  tput civis

  machine_name="$1"
  check_machine_name="$(jq --arg searched_machine "$machine_name" 'map(del(.[].[1,2,3,4,5,7])) | map(select(.[].[0].v | test("\\b\($searched_machine)\\b"; "i"))) | length' htbmachines.json)"

  if [ $check_machine_name -ne 0 ]; then
    echo -e "\n${yellowColour}[+]${endColour} ${grayColour}El tutorial para la máquina${endColour} ${blueColour}$machine_name${endColour}${grayColour} está en el siguiente enlace:${endColour}\n"
    echo -e "${purpleColour}$(jq -r --arg searched_machine "$machine_name" 'map(del(.[].[1,2,3,4,5,7])) | map(select(.[].[0].v | test("\\b\($searched_machine)\\b"; "i"))) | .[].c.[1].v' htbmachines.json)${endColour}"
  else
    echo -e "\n${redColour}[!] La máquina proporcionada no existe${endColour}"
  fi

  tput cnorm
}

declare -i parameter_counter=0

while getopts "um:i:o:d:s:c:y:h" arg; do
  case $arg in
    u) let parameter_counter+=1;;
    m) machine_name="$OPTARG"; let parameter_counter+=2;;
    i) ip_address="$OPTARG"; let parameter_counter+=3;;
    o) os="$OPTARG"; let parameter_counter+=4;;
    d) difficulty="$OPTARG"; let parameter_counter+=5;;
    s) skill="$OPTARG"; let parameter_counter+=6;;
    c) cert="$OPTARG"; let parameter_counter+=7;;
    y) machine_name="$OPTARG"; let parameter_counter+=8;;
    h) ;;
  esac
done

if [ $parameter_counter -eq 1 ]; then
  update_files
elif [ $parameter_counter -eq 2 ]; then
  search_machine $machine_name
elif [ $parameter_counter -eq 3 ]; then
  search_ip $ip_address
elif [ $parameter_counter -eq 4 ]; then
  get_os_machines $os
elif [ $parameter_counter -eq 5 ]; then
  get_machines_difficulty $difficulty
elif [ $parameter_counter -eq 6 ]; then
  get_skill "$skill"
elif [ $parameter_counter -eq 7 ]; then
  get_cert "$cert"
elif [ $parameter_counter -eq 8 ]; then
  get_youtube_link "$machine_name"
else
  help_panel
fi
