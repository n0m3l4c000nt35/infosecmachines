## Descargar

```shell
wget https://raw.githubusercontent.com/n0m3l4c000nt35/infosecmachines/main/infosecmachines.sh
```

## Darle permisos de ejecución

```shell
chmod +x infosecmachines.sh
```

## Solución de problemas

Transferir scripts entre diferentes sistemas operativos (como Windows y Linux) puede introducir caracteres invisibles en un script, como retornos de carro (\r). Estos caracteres pueden causar el error '/bin/bash^M: bad interpreter: No such file or directory' error.
Para solucionar este problema prueben instalando `dos2unix` y pasarle el script.

```shell
dos2unix infosecmachines.sh
```
