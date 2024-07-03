#!/bin/bash

# Colours
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"

API_URL="https://infosecmachines.io/api/machines"

function ctrl_c(){
  echo -e "\n${redColour}[!] Saliendo...${endColour}"
  tput cnorm && exit 1
}

trap ctrl_c INT

function help_panel(){
  echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Uso:${endColour}"
  echo -e "\t${purpleColour}a)${endColour} ${grayColour}Listar todas las máquinas${endColour}"
  echo -e "\t${purpleColour}m)${endColour} ${grayColour}Buscar por nombre de máquina${endColour}"
  echo -e "\t${purpleColour}i)${endColour} ${grayColour}Buscar por dirección IP${endColour}"
  echo -e "\t${purpleColour}o)${endColour} ${grayColour}Buscar por el sistema operativo${endColour}"
  echo -e "\t${purpleColour}d)${endColour} ${grayColour}Buscar por la dificultad de una máquina${endColour}"
  echo -e "\t${purpleColour}t)${endColour} ${grayColour}Buscar por técnica${endColour}"
  echo -e "\t${purpleColour}c)${endColour} ${grayColour}Buscar por certificación${endColour}"
  echo -e "\t${purpleColour}y)${endColour} ${grayColour}Obtener link de la resolución de la máquina en YouTube${endColour}"
  echo -e "\t${purpleColour}p)${endColour} ${grayColour}Listar máquinas por plataforma${endColour}"
  echo -e "\n${yellowColour}[+]${endColour} Excel: ${blueColour}https://docs.google.com/spreadsheets/d/1dzvaGlT_0xnT-PGO27Z_4prHgA8PHIpErmoWdlUrSoA/edit#gid=0${endColour}"
  echo -e "${yellowColour}[+]${endColour} Web infosecmachines: ${blueColour}https://infosecmachines.io/${endColour}"
  tput cnorm
}

function all_machines(){
  echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Listando todas las máquinas:${endColour}\n"
  machines=$(curl -s "$API_URL" | jq -r .newData.[].name | sort)
  echo "$machines" | column
  total_machines=$(echo "$machines" | wc -l)
  echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Total de máquinas:${endColour} ${greenColour}$total_machines${endColour}"
  tput cnorm
}

function search_machine(){
  machine_name="$1"
  check_machine_name="$(curl -s "$API_URL" | jq -r --arg searched_machine "$machine_name" '.newData[] | select(.name | test("(?i)^\\b\($searched_machine)\\b$"))')"

  if [ -n "$check_machine_name" ]; then

    echo -e "\n${yellowColour}[+] ${grayColour}Listando las propiedades de la máquina${endColour} ${blueColour}$machine_name${endColour}${grayColour}:${endColour}\n"
    keys=("Máquina" "Dirección IP" "Sistema Operativo" "Dificultad" "Técnicas" "Certificaciones" "Writeup" "Plataforma")

    echo -e "${greenColour}${keys[0]}${endColour}: $(echo "$check_machine_name" | jq -r '.name')"

    ip=$(echo "$check_machine_name" | jq -r '.ip')
    if [ "$ip" = "null" ] || [ -z "$ip" ]; then
      echo -e "${greenColour}${keys[1]}${endColour}: ${redColour}La dirección IP no se indicó${endColour}"
    else
      echo -e "${greenColour}${keys[1]}${endColour}: $ip"
    fi

    os=$(echo "$check_machine_name" | jq -r '.os')
    if [ "$os" = "null" ] || [ -z "$os" ]; then
      echo -e "${greenColour}${keys[2]}${endColour}: ${redColour}El sistema operativo no se indicó${endColour}"
    else
      echo -e "${greenColour}${keys[2]}${endColour}: $os"
    fi
    
    difficulty=$(echo "$check_machine_name" | jq -r '.state')
    if [ "$difficulty" = "null" ] || [ -z "$difficulty" ]; then
      echo -e "${greenColour}${keys[3]}${endColour}: ${redColour}La dificultad no se indicó${endColour}"
    else
      echo -e "${greenColour}${keys[3]}${endColour}: $difficulty"
    fi

    echo -e "${greenColour}${keys[4]}${endColour}:"; echo "$(echo "$check_machine_name" | jq -r '.techniques')" | while read skill; do echo -e "  ${purpleColour}-${endColour} $skill"; done
    echo -e "${greenColour}${keys[5]}${endColour}:"; echo "$(echo "$check_machine_name" | jq -r '.certification')" | while read cert; do echo -e "  ${purpleColour}-${endColour} $cert"; done
    echo -e "${greenColour}${keys[6]}${endColour}: $(echo "$check_machine_name" | jq -r '.video')"
    echo -e "${greenColour}${keys[7]}${endColour}: $(echo "$check_machine_name" | jq -r '.platform')"

  else
    echo -e "\n${redColour}[!]${endColour} ${grayColour}La máquina proporcionada no existe${endColour}\n"
  fi
  tput cnorm
}

function search_ip(){
  ip_address="$1"
  check_ip_address="$(curl -s "$API_URL" | jq -r --arg searched_ip "$ip_address" '.newData[] | select(.ip | test("\\b\($searched_ip)\\b"; "i"))')"

  if [ -n "$check_ip_address" ]; then
    echo -e "\n${yellowColour}[+]${endColour} ${grayColour}La máquina correspondiente para la IP${endColour} ${blueColour}$ip_address${endColour} ${grayColour}es:${endColour} ${purpleColour}"$(echo "$check_ip_address" | jq -r '.name')"${endColour}"
  else
    echo -e "\n${redColour}[!]${endColour} ${grayColour}La dirección IP proporcionada no existe${endColour}"
  fi
  tput cnorm
}

function get_os_machines(){
  os="$1"
  check_os="$(curl -s "$API_URL" | jq -r --arg searched_os "$os" '.newData[] | select(.os | test("\\b\($searched_os)\\b"; "i")) | .name')"

  if [ -n "$check_os" ]; then
    echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Mostrando las máquinas cuyo sistema operativo es${endColour} ${blueColour}$os${endColour}${grayColour}:${endColour}\n"
    echo "$check_os" | sort | column
  else
    echo -e "\n${redColour}[!]${endColour} ${grayColour}El sistema operativo indicado no existe${endColour}"
  fi
  tput cnorm
}

function get_machines_difficulty(){
  difficulty="$1"
  check_difficulty="$(curl -s "$API_URL" | jq -r --arg searched_difficulty "$difficulty" '.newData[] | select(.state | test("\\b\($searched_difficulty)\\b"; "i"))')"

  if [ -n "$check_difficulty" ]; then
    echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Mostrando las máquinas que poseen un nivel de dificultad${endColour} ${blueColour}$difficulty${endColour}${grayColour}:${endColour}\n"
    echo "$check_difficulty" | jq -r '.name' | sort | column
  else
    echo -e "\n${redColour}[!]${endColour} ${grayColour}La dificultad indicada no existe${endColour}\n"
    echo -e "${grayColour}Ingresa una de las siguientes dificultades:${endColour}\n\n ${grayColour}-${endColour} ${greenColour}Easy${endColour}\n ${grayColour}-${endColour} ${yellowColour}Medium${endColour}\n ${grayColour}-${endColour} ${purpleColour}Hard${endColour}\n ${grayColour}-${endColour} ${redColour}Insane${endColour}"
  fi
  tput cnorm
}

function get_technique(){
  technique="$1"
  check_technique="$(curl -s "$API_URL" | jq -r --arg searched_technique "$technique" '.newData[] | select(.techniques | test("\\b\($searched_technique)\\b"; "i"))')"

  if [ -n "$check_technique" ]; then
    echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Mostrando las máquinas donde se ve la técnica${endColour} ${blueColour}$technique${endColour}${grayColour}:${endColour}\n"
    echo "$check_technique" | jq -r '.name' | sort | column
  else
    echo -e "\n${redColour}[!]${endColour} ${grayColour}No se ha encontrado ninguna máquina con la técnica indicada${endColour}"
  fi
  tput cnorm
}

function get_certification(){
  certification="$1"
  check_certification="$(curl -s "$API_URL" | jq -r --arg searched_certification "$certification" '.newData[] | select(.certification | test("\\b\($searched_certification)\\b"; "i")) | .name')"

  if [ -n "$check_certification" ]; then
    echo -e "\n${yellowColour}[+]${endColour} ${grayColour}A continuación se presentan las máquinas que te preparan para la certificación${endColour} ${blueColour}$cert${endColour}${grayColour}:${endColour}\n"
    echo "$check_certification" | sort | column
  else
    echo -e "\n${redColour}[!]${endColour} ${grayColour}No se ha encontrado ninguna máquina para la certificación indicada${endColour}"
  fi
  tput cnorm
}

function get_youtube_link(){
  machine_name="$1"
  check_machine_name="$(curl -s "$API_URL" | jq -r --arg searched_machine "$machine_name" '.newData[] | select(.name | test("\\b\($searched_machine)\\b"; "i")) | .video')"

  if [ -n "$check_machine_name" ]; then
    echo -e "\n${yellowColour}[+]${endColour} ${grayColour}El tutorial para la máquina${endColour} ${blueColour}$machine_name${endColour}${grayColour} está en el siguiente enlace:${endColour}\n"
    echo -e "${purpleColour}$check_machine_name${endColour}" | sort | column
  else
    echo -e "\n${redColour}[!]${endColour} ${grayColour}La máquina proporcionada no existe${endColour}"
  fi
  tput cnorm
}

function get_difficulty_os(){
  difficulty="$1"
  os="$2"

  check_difficulty="$(curl -s "$API_URL" | jq -r --arg searched_difficulty "$difficulty" '.newData[] | select(.state | test("\\b\($searched_difficulty)\\b"; "i")) | .state')"
  check_os="$(curl -s "$API_URL" | jq -r --arg searched_os "$os" '.newData[] | select(.os | test("\\b\($searched_os)\\b"; "i")) | .os')"

  if [ -n "$check_difficulty" ] && [ -n "$check_os" ]; then
    echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Listando máquinas de dificultad${endColour} ${blueColour}$difficulty${endColour} ${grayColour}que tengan el sistema operativo${endColour} ${blueColour}$os${endColour}${grayColour}:${endColour}\n"
    echo -e "$(curl -s "$API_URL" | jq -r --arg searched_difficulty "$difficulty" --arg searched_os "$os" '.newData[] | select(.state | test("\\b\($searched_difficulty)\\b"; "i")) | select(.os | test("\\b\($searched_os)\\b"; "i")) | .name' | sort | column)"
  else
    echo -e "\n${redColour}[!]${endColour} ${grayColour}Se ha indicado una dificultad o sistema operativo incorrectos${endColour}"
  fi
  tput cnorm
}

function get_machines_by_platform(){
  platform="$1"

  check_platform="$(curl -s "$API_URL" | jq -r --arg searched_platform "$platform" '.newData[] | select(.platform | test("\\b\($searched_platform)\\b"; "i"))')"

  if [ -n "$check_platform" ]; then
    echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Listando máquinas pertenecientes a la plataforma${endColour} ${blueColour}$platform${endColour}${grayColour}:${endColour}\n"
    echo "$check_platform" | jq -r '.name' | sort | column
  else
    echo -e "\n${redColour}[!]${endColour} ${grayColour}La plataforma indicada no existe${endColour}"
    echo -e "\n${grayColour}Selecciona una de las siguientes plataformas:${endColour}\n\n ${grayColour}-${endColour} ${greenColour}HackTheBox${endColour}\n ${grayColour}-${endColour} ${turquoiseColour}VulnHub${endColour}\n ${grayColour}-${endColour} ${yellowColour}PortSwigger${endColour}\n"
  fi
  tput cnorm
}

declare -i parameter_counter=0
declare -i difficulty_wd=0
declare -i os_wd=0

tput civis; while getopts ":uam:i:o:d:t:c:y:p:h" opt; do
  case $opt in
    a) let parameter_counter+=1;;
    m) machine_name="$OPTARG"; let parameter_counter+=2;;
    i) ip_address="$OPTARG"; let parameter_counter+=3;;
    o) os="$OPTARG"; os_wd=1; let parameter_counter+=4;;
    d) difficulty="$OPTARG"; difficulty_wd=1; let parameter_counter+=5;;
    t) technique="$OPTARG"; let parameter_counter+=6;;
    c) certification="$OPTARG"; let parameter_counter+=7;;
    y) machine_name="$OPTARG"; let parameter_counter+=8;;
    p) platform="$OPTARG"; let parameter_counter+=9;;
    h) ;;
    \?) echo -e "\n${redColour}[!]${endColour} Opción inválida: ${blueColour}-$OPTARG${endColour}" >&2
      help_panel
      exit 1;;
    :)
      tput cnorm
      case $OPTARG in
        m)
          echo -e "\n${redColour}[!]${endColour} Ingresa el nombre de una máquina"
          echo -e "\n${yellowColour}[+]${endColour} Uso: ./infosecmachines.sh -m ${blueColour}<maquina>${endColour}"
          exit 1;;
        i)
          echo -e "\n${redColour}[!]${endColour} Ingresa una dirección IP"
          echo -e "\n${yellowColour}[+]${endColour} Uso: ./infosecmachines.sh -i ${blueColour}<dirección-ip>${endColour}"
          exit 1;;
        o)
          echo -e "\n${redColour}[!]${endColour} Ingresa el sistema operativo: ${purpleColour}Linux${endColour} | ${purpleColour}Windows${endColour}"
          echo -e "\n${yellowColour}[+]${endColour} Uso: ./infosecmachines.sh -i ${blueColour}<sistema-operativo>${endColour}"
          exit 1;;
        d)
          echo -e "\n${redColour}[!]${endColour} Ingresa la dificultad: ${purpleColour}Easy${endColour} | ${purpleColour}Medium${endColour} | ${purpleColour}Hard${endColour} | ${purpleColour}Insane${endColour}"
          echo -e "\n${yellowColour}[+]${endColour} Uso: ./infosecmachines.sh -i ${blueColour}<dificultad>${endColour}"
          exit 1;;

      esac
  esac
done


if [ $parameter_counter -eq 1 ]; then
  all_machines
elif [ $parameter_counter -eq 2 ]; then
  if [ -z "$OPTARG" ]; then
    echo "ERROR"
  else
    search_machine "$machine_name"
  fi
elif [ $parameter_counter -eq 3 ]; then
  search_ip $ip_address
elif [ $parameter_counter -eq 4 ]; then
  get_os_machines $os
elif [ $parameter_counter -eq 5 ]; then
  get_machines_difficulty $difficulty
elif [ $parameter_counter -eq 6 ]; then
  get_technique "$technique"
elif [ $parameter_counter -eq 7 ]; then
  get_certification "$certification"
elif [ $parameter_counter -eq 8 ]; then
  get_youtube_link "$machine_name"
elif [ $parameter_counter -eq 9 ]; then
  get_machines_by_platform "$platform"
elif [ $difficulty_wd -eq 1 ] && [ $os_wd -eq 1 ]; then
  get_difficulty_os $difficulty $os
else
  help_panel
fi
