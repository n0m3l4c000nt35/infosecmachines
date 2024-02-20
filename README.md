## Descarga

```shell
wget https://raw.githubusercontent.com/n0m3l4c000nt35/infosecmachines/main/infosecmachines.sh
```

Dale permisos de ejecución

```shell
chmod +x infosecmachines.sh
```

## Solución de problemas

Transferir scripts entre diferentes sistemas operativos (como Windows y Linux) puede introducir caracteres invisibles en un script, como retornos de carro `\r`. Estos caracteres pueden causar el error `'/bin/bash^M: bad interpreter: No such file or directory' error`.
Para solucionar este problema prueben instalando `dos2unix` y pasarle el script.

```shell
dos2unix infosecmachines.sh
```

##### Basado en:
###### - El Excel [Planning de Estudio con S4vitar [Preparación OSCP, OSED, OSWE, OSEP, eJPT, eWPT, eWPTXv2, eCPPTv2, eCPTXv2]](https://docs.google.com/spreadsheets/d/1dzvaGlT_0xnT-PGO27Z_4prHgA8PHIpErmoWdlUrSoA/edit#gid=0) creado por S4vitar.
###### - La web [https://infosecmachines.io/](https://infosecmachines.io/) creada por [JavierMolines](https://github.com/JavierMolines/).
###### - La web [https://htbmachines.github.io/](https://htbmachines.github.io/) creada por [rroderickk](https://github.com/rroderickk).

#### Creado por [n0m3l4c000nt35](https://github.com/n0m3l4c000nt35) ♥ para la comunidad de [Hack4u](https://hack4u.io/)
