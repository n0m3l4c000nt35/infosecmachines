# InfoSecMachines

## Características

- Listar todas las máquinas disponibles
- Buscar máquinas por nombre
- Buscar máquinas por dirección IP
- Filtrar máquinas por sistema operativo -> **Linux** | **Windows**
- Filtrar máquinas por nivel de dificultad -> **Easy** | **Medium** | **Hard** | **Insane**
- Buscar máquinas por técnicas específicas
- Buscar máquinas por certificaciones relacionadas
- Obtener enlaces de tutoriales en YouTube para máquinas específicas
- Filtrar máquinas por plataforma -> **HackTheBox** | **VulnHub** | **PortSwigger**
- Filtrado avanzado combinando múltiples criterios
- Modo interactivo para una experiencia de usuario más amigable
- Sistema de caché para mejorar el rendimiento y reducir las llamadas a la API

## Requisitos

- Bash
- curl
- jq
- column

## Descarga

```shell
sudo wget -P /usr/bin/ https://raw.githubusercontent.com/n0m3l4c000nt35/infosecmachines/main/infosecmachines
sudo wget -O /usr/bin/infosecmachines https://raw.githubusercontent.com/n0m3l4c000nt35/infosecmachines/main/infosecmachines
```

## Permisos

```shell
chmod +x infosecmachines
```

## Uso

Para ver todas las opciones disponibles, ejecuta:
`infosecmachines -h`

Ejemplos de uso:

- Listar todas las máquinas:
`infosecmachines -a`

- Buscar una máquina por nombre:
`infosecmachines -m lame`, `infosecmachines -m "HackNos: Player V1.1"`

- Filtrar máquinas por sistema operativo:
`infosecmachines -o linux`

- Buscar máquinas por dificultad:
`infosecmachines -d medium`

- Buscar máquinas por técnica:
`infosecmachines -t "buffer overflow"`

- Filtrado avanzado (combinando múltiples criterios):
`infosecmachines -o Linux -d Hard -t "Buffer Overflow" -c OSCP -p HackTheBox`

- Iniciar el modo interactivo:
`infosecmachines -I`

## Filtrado Avanzado

El filtrado avanzado te permite combinar múltiples criterios para una búsqueda más precisa. Puedes usar las siguientes flags combinadas:

- `-o`: Sistema operativo
- `-d`: Dificultad
- `-t`: Técnica
- `-c`: Certificación
- `-p`: Plataforma

---

##### Basado en:
###### - Excel [Planning de Estudio con S4vitar [Preparación OSCP, OSED, OSWE, OSEP, eJPT, eWPT, eWPTXv2, eCPPTv2, eCPTXv2]](https://docs.google.com/spreadsheets/d/1dzvaGlT_0xnT-PGO27Z_4prHgA8PHIpErmoWdlUrSoA/edit#gid=0) creado por [S4vitar](https://github.com/s4vitar).
###### - Web [https://infosecmachines.io/](https://infosecmachines.io/) creada por [JavierMolines](https://github.com/JavierMolines/).
###### - Web [https://htbmachines.github.io/](https://htbmachines.github.io/) creada por [rroderickk](https://github.com/rroderickk).

#### Creado por [n0m3l4c000nt35](https://github.com/n0m3l4c000nt35) ♥ para la comunidad de [Hack4u](https://hack4u.io/)
