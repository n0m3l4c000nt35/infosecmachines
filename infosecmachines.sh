#!/usr/bin/env bash

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

function check_jq() {
  if ! command -v jq &> /dev/null; then
    echo -e "\n${redColour}[!]${endColour} La herramienta ${greenColour}jq${endColour} no está instalada. Instalando..."
    if [ -x "$(command -v apt)" ]; then
      sudo apt update && sudo apt install -y jq
    elif [ -x "$(command -v apt-get)" ]; then
      sudo apt-get update && sudo apt-get install -y jq
    elif [ -x "$(command -v yum)" ]; then
      sudo yum install -y jq
    elif [ -x "$(command -v dnf)" ]; then
      sudo dnf install -y jq
    elif [ -x "$(command -v pacman)" ]; then
      sudo pacman -S --noconfirm jq
    elif [ -x "$(command -v zypper)" ]; then
      sudo zypper install -y jq
    else
      echo -e "\n${redColour}[!]${endColour} No se pudo instalar ${greenColour}jq${endColour} automáticamente. Por favor, instálalo manualmente."
      exit 1
    fi
    echo -e "\n${greenColour}[✓]${endColour} ${greenColour}jq${endColour} se ha instalado exitosamente."
  fi
}

check_jq

function banner(){
  echo -e "${redColour}
 _       ___                                       _    _
|_| ___ |  _| ___  ___  ___  ___  _____  ___  ___ | |_ |_| ___  ___  ___ 
| ||   ||  _|| . ||_ -|| -_||  _||     || .'||  _||   || ||   || -_||_ -|
|_||_|_||_|  |___||___||___||___||_|_|_||__,||___||_|_||_||_|_||___||___|${endColour}"
}

function help_panel(){
  echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Uso:${endColour}"
  echo -e "\t${purpleColour}a${endColour}${turquoiseColour})${endColour} ${grayColour}Listar todas las máquinas${endColour}"
  echo -e "\t${purpleColour}m${endColour}${turquoiseColour})${endColour} ${grayColour}Buscar por nombre de máquina${endColour}"
  echo -e "\t${purpleColour}i${endColour}${turquoiseColour})${endColour} ${grayColour}Buscar por dirección IP${endColour}"
  echo -e "\t  ${purpleColour}l${endColour}${turquoiseColour})${endColour} ${grayColour}Listar todas las direcciones IP${endColour}"
  echo -e "\t${purpleColour}o${endColour}${turquoiseColour})${endColour} ${grayColour}Buscar por el sistema operativo${endColour}: ${purpleColour}Linux${endColour} | ${purpleColour}Windows${endColour}"
  echo -e "\t${purpleColour}d${endColour}${turquoiseColour})${endColour} ${grayColour}Buscar por la dificultad de una máquina${endColour}: ${purpleColour}Easy${endColour} | ${purpleColour}Medium${endColour} | ${purpleColour}Hard${endColour} | ${purpleColour}Insane${endColour}"
  echo -e "\t${purpleColour}t${endColour}${turquoiseColour})${endColour} ${grayColour}Buscar por técnica${endColour}"
  echo -e "\t  ${purpleColour}l${endColour}${turquoiseColour})${endColour} ${grayColour}Listar todas las técnicas${endColour}"
  echo -e "\t${purpleColour}c${endColour}${turquoiseColour})${endColour} ${grayColour}Buscar por certificación${endColour}"
  echo -e "\t${purpleColour}y${endColour}${turquoiseColour})${endColour} ${grayColour}Obtener link de la resolución de la máquina en YouTube${endColour}"
  echo -e "\t${purpleColour}p${endColour}${turquoiseColour})${endColour} ${grayColour}Listar máquinas por plataforma${endColour}: ${purpleColour}HackTheBox${endColour} | ${purpleColour}VulnHub${endColour} | ${purpleColour}PortSwigger${endColour}"
  echo -e "\n${yellowColour}[+]${endColour} Excel: ${blueColour}https://docs.google.com/spreadsheets/d/1dzvaGlT_0xnT-PGO27Z_4prHgA8PHIpErmoWdlUrSoA/edit#gid=0${endColour}"
  echo -e "${yellowColour}[+]${endColour} Web infosecmachines: ${blueColour}https://infosecmachines.io/${endColour}"
  tput cnorm
}

function all_machines(){
  echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Listando todas las máquinas:${endColour}\n"
  machines=$(curl -s "$API_URL" | jq -r '.newData[].name' | sort)
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
  if [ "$1" == "-l" ]; then
    echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Listando todas las direcciones IP:${endColour}\n"
    curl -s "$API_URL" | jq -r '.newData[] | select(.ip != null and .ip != "") | .ip' | sort -u | column
    echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Total de IPs únicas:${endColour} ${greenColour}$(curl -s "$API_URL" | jq -r '.newData[] | select(.ip != null and .ip != "") | .ip' | sort -u | wc -l)${endColour}"
  else
    ip_address="$1"
    check_ip_address="$(curl -s "$API_URL" | jq -r --arg searched_ip "$ip_address" '.newData[] | select(.ip | test("\\b\($searched_ip)\\b"; "i"))')"

    if [ -n "$check_ip_address" ]; then
      echo -e "\n${yellowColour}[+]${endColour} ${grayColour}La máquina correspondiente para la IP${endColour} ${blueColour}$ip_address${endColour} ${grayColour}es:${endColour} ${purpleColour}"$(echo "$check_ip_address" | jq -r '.name')"${endColour}"
    else
      echo -e "\n${redColour}[!]${endColour} ${grayColour}La dirección IP proporcionada no existe${endColour}"
    fi
  fi
  tput cnorm
}

function get_os_machines(){
  os="$1"
  check_os="$(curl -s "$API_URL" | jq -r --arg searched_os "$os" '.newData[] | select(.os | test("\\b\($searched_os)\\b"; "i")) | .name')"

  if [ -n "$check_os" ]; then
    echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Mostrando las máquinas cuyo sistema operativo es${endColour} ${blueColour}$os${endColour}${grayColour}:${endColour}\n"
    echo "$check_os" | sort | column
    echo -e "\n${yellowColour}[+]${endColour} Total de máquinas: ${greenColour}$(echo "$check_os" | wc -l)${endColour}"
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
    echo -e "\n${yellowColour}[+]${endColour} Total de máquinas: ${greenColour}$(echo "$check_difficulty" | jq -r '.name' | wc -l)${endColour}"
  else
    echo -e "\n${redColour}[!]${endColour} ${grayColour}La dificultad indicada no existe${endColour}\n"
    echo -e "${grayColour}Ingresa una de las siguientes dificultades:${endColour}\n\n ${grayColour}-${endColour} ${greenColour}Easy${endColour}\n ${grayColour}-${endColour} ${yellowColour}Medium${endColour}\n ${grayColour}-${endColour} ${purpleColour}Hard${endColour}\n ${grayColour}-${endColour} ${redColour}Insane${endColour}"
  fi
  tput cnorm
}

function get_technique(){
  if [ "$1" == "-l" ]; then
    echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Listando todas las técnicas disponibles:${endColour}\n"
    curl -s "$API_URL" | jq -r '.newData[].techniques | split("\n")[] | select(length > 0)' | sort -u | column
    echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Total de técnicas:${endColour} ${greenColour}$(curl -s "$API_URL" | jq -r '.newData[].techniques | split("\n")[] | select(length > 0)' | sort -u | wc -l)${endColour}"
  else
    technique="$1"
    check_technique="$(curl -s "$API_URL" | jq -r --arg searched_technique "$technique" '.newData[] | select(.techniques | split("\n") | map(. | ascii_downcase) | contains([$searched_technique | ascii_downcase]))')"
    if [ -n "$check_technique" ]; then
      echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Mostrando las máquinas donde se ve la técnica${endColour} ${blueColour}$technique${endColour}${grayColour}:${endColour}\n"
      echo "$check_technique" | jq -r '.name' | sort | column
      echo -e "\n${yellowColour}[+]${endColour} Total de máquinas: ${greenColour}$(echo "$check_technique" | jq -r '.name' | wc -l)${endColour}"
    else
      echo -e "\n${redColour}[!]${endColour} ${grayColour}No se ha encontrado ninguna máquina con la técnica indicada${endColour}"
    fi
  fi
  tput cnorm
}

function get_certification(){
  certification="$1"
  escaped_certification=$(printf '%s' "$certification" | sed 's/[^^]/[&]/g; s/\^/\\^/g')
  check_certification="$(curl -s "$API_URL" | jq -r --arg searched_certification "$escaped_certification" '.newData[] | select(.certification | test("\($searched_certification)"; "i")) | .name')"

  if [ -n "$check_certification" ]; then
    echo -e "\n${yellowColour}[+]${endColour} ${grayColour}A continuación se presentan las máquinas que te preparan para la certificación${endColour} ${blueColour}$certification${endColour}${grayColour}:${endColour}\n"
    echo "$check_certification" | sort | column
    echo -e "\n${yellowColour}[+]${endColour} Total de máquinas: ${greenColour}$(echo "$check_certification" | wc -l)${endColour}"
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

function get_machines_by_platform(){
  platform="$1"

  check_platform="$(curl -s "$API_URL" | jq -r --arg searched_platform "$platform" '.newData[] | select(.platform | test("\\b\($searched_platform)\\b"; "i"))')"

  if [ -n "$check_platform" ]; then
    echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Listando máquinas pertenecientes a la plataforma${endColour} ${blueColour}$platform${endColour}${grayColour}:${endColour}\n"
    echo "$check_platform" | jq -r '.name' | sort | column
    echo -e "\n${yellowColour}[+]${endColour} Total de máquinas: ${greenColour}$(echo "$check_platform" | jq -r '.name' | wc -l)${endColour}"
  else
    echo -e "\n${redColour}[!]${endColour} ${grayColour}La plataforma indicada no existe${endColour}"
    echo -e "\n${grayColour}Selecciona una de las siguientes plataformas:${endColour}\n\n ${grayColour}-${endColour} ${greenColour}HackTheBox${endColour}\n ${grayColour}-${endColour} ${turquoiseColour}VulnHub${endColour}\n ${grayColour}-${endColour} ${yellowColour}PortSwigger${endColour}\n"
  fi
  tput cnorm
}

function get_difficulty_os(){
  difficulty="$1"
  os="$2"
  
  check_machines="$(curl -s "$API_URL" | jq -r --arg searched_difficulty "$difficulty" --arg searched_os "$os" '.newData[] | select(.state | test("\\b\($searched_difficulty)\\b"; "i")) | select(.os | test("\\b\($searched_os)\\b"; "i")) | .name')"

  if [ -n "$check_machines" ]; then
    echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Listando máquinas de dificultad${endColour} ${blueColour}$difficulty${endColour} ${grayColour}que tengan el sistema operativo${endColour} ${blueColour}$os${endColour}${grayColour}:${endColour}\n"
    echo "$check_machines" | sort | column
  else
    echo -e "\n${redColour}[!]${endColour} ${grayColour}No se encontraron máquinas con la dificultad${endColour} ${blueColour}$difficulty${endColour} ${grayColour}y el sistema operativo${endColour} ${blueColour}$os${endColour}"
  fi
  tput cnorm
}

declare -i a_flag=0 m_flag=0 i_flag=0 o_flag=0 d_flag=0 t_flag=0 c_flag=0 y_flag=0 p_flag=0

tput civis; banner; while getopts ":am:i:o:d:t:c:y:p:h" opt; do
  case $opt in
    a) a_flag=1;;
    m) machine_name="$OPTARG"; m_flag=1;;
    i) 
      if [ "$OPTARG" == "-l" ]; then
        i_flag=2
      else
        ip_address="$OPTARG"
        i_flag=1
      fi
      ;;
    o) os="$OPTARG"; o_flag=1;;
    d) difficulty="$OPTARG"; d_flag=1;;
    t)
      if [ "$OPTARG" == "-l" ]; then
        t_flag=2  # Usamos 2 para indicar que queremos listar todas las técnicas
      else
        technique="$OPTARG"
        t_flag=1
      fi
      ;;
    c) certification="$OPTARG"; c_flag=1;;
    y) machine_name="$OPTARG"; y_flag=1;;
    p) platform="$OPTARG"; p_flag=1;;
    h) ;;
    \?) echo -e "\n${redColour}[!]${endColour} Opción inválida: ${blueColour}-$OPTARG${endColour}" >&2
      help_panel
      exit 1;;
    :)
      tput cnorm
      case $OPTARG in
        m)
          echo -e "\n${redColour}[!]${endColour} Ingresa el nombre de la máquina"
          echo -e "\n${yellowColour}[+]${endColour} Uso:\n\t./infosecmachines.sh -m ${blueColour}<maquina>${endColour}"
          echo -e "\t./infosecmachines.sh -m ${blueColour}\"<máquina> <buscada>\"${endColour}\tIngresa el nombre de la máquina entre comillas si involucra más de una palabra"
          exit 1;;
        i)
          echo -e "\n${redColour}[!]${endColour} Ingresa la dirección IP"
          echo -e "\n${yellowColour}[+]${endColour} Uso:\n\t./infosecmachines.sh -i ${blueColour}<dirección-ip>${endColour}"
          echo -e "\t./infosecmachines.sh -i -l\tLista todas las direcciones IP"
          exit 1;;
        o)
          echo -e "\n${redColour}[!]${endColour} Ingresa el sistema operativo: ${purpleColour}Linux${endColour} | ${purpleColour}Windows${endColour}"
          echo -e "\n${yellowColour}[+]${endColour} Uso: ./infosecmachines.sh -o ${blueColour}<sistema-operativo>${endColour}"
          exit 1;;
        d)
          echo -e "\n${redColour}[!]${endColour} Ingresa la dificultad: ${purpleColour}Easy${endColour} | ${purpleColour}Medium${endColour} | ${purpleColour}Hard${endColour} | ${purpleColour}Insane${endColour}"
          echo -e "\n${yellowColour}[+]${endColour} Uso: ./infosecmachines.sh -d ${blueColour}<dificultad>${endColour}"
          exit 1;;
        t)
          echo -e "\n${redColour}[!]${endColour} Ingresa la técnica"
          echo -e "\n${yellowColour}[+]${endColour} Uso:\n\t./infosecmachines.sh -t ${blueColour}<técnica>${endColour}"
          echo -e "\t./infosecmachines.sh -t ${blueColour}\"<técnica> <buscada>\"${endColour}\tIngresa la técnica entre comillas si involucra más de una palabra"
          exit 1;;
        c)
          echo -e "\n${redColour}[!]${endColour} Ingresa la certificación:\n"
          echo "$(curl -s "https://infosecmachines.io/api/machines" | jq -r '.newData[].certification' | sort -u)" | while read tech; do echo -e "${purpleColour}-${endColour} $tech"; done
          echo -e "\n${yellowColour}[+]${endColour} Uso:\n\t./infosecmachines.sh -c ${blueColour}<certificación>${endColour}"
          echo -e "\t./infosecmachines.sh -c ${blueColour}\"<certificación> <buscada>\"${endColour}\tIngresa la certificación entre comillas si involucra más de una palabra"
          exit 1;;
        y)
          echo -e "\n${redColour}[!]${endColour} Ingresa el nombre de la máquina"
          echo -e "\n${yellowColour}[+]${endColour} Uso:\n\t./infosecmachines.sh -y ${blueColour}<maquina>${endColour}"
          echo -e "\t./infosecmachines.sh -y ${blueColour}\"<máquina> <buscada>\"${endColour}\tIngresa el nombre de la máquina entre comillas si involucra más de una palabra"
          exit 1;;
        p)
          echo -e "\n${redColour}[!]${endColour} Ingresa la plataforma: ${purpleColour}HackTheBox${endColour} | ${purpleColour}VulnHub${endColour} | ${purpleColour}PortSwigger${endColour}"
          echo -e "\n${yellowColour}[+]${endColour} Uso: ./infosecmachines.sh -p ${blueColour}<plataforma>${endColour}"
          exit 1;;
      esac
  esac
done

if [ $a_flag -eq 1 ]; then
  all_machines
elif [ $m_flag -eq 1 ]; then
  search_machine "$machine_name"
elif [ $i_flag -eq 1 ]; then
  search_ip "$ip_address"
elif [ $i_flag -eq 2 ]; then
  search_ip "-l"
elif [ $o_flag -eq 1 ] && [ $d_flag -eq 1 ]; then
  get_difficulty_os "$difficulty" "$os"
elif [ $o_flag -eq 1 ]; then
  get_os_machines $os
elif [ $d_flag -eq 1 ]; then
  get_machines_difficulty $difficulty
elif [ $t_flag -eq 1 ]; then
  get_technique "$technique"
elif [ $t_flag -eq 2 ]; then
  get_technique "-l"
elif [ $c_flag -eq 1 ]; then
  get_certification "$certification"
elif [ $y_flag -eq 1 ]; then
  get_youtube_link "$machine_name"
elif [ $p_flag -eq 1 ]; then
  get_machines_by_platform $platform
else
  help_panel
fi

### n0m3l4c000nt35 ###
