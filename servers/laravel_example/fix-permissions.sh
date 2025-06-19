#!/bin/bash 

# Archivo para automatizar los permisos del proyecto

echo "Corrigiendo permisos..."


# 1. Dar permisos correctos de dueño y grupo: El usuario será jose, el grupo será www-data (el grupo de Nginx o Apache).
#Esto hace que tú tengas control como usuario, y que el servidor web pueda acceder bien.
#Todos los archivos y carpetas dentro www
sudo chown -R jose:www-data www


# 2. Dar permisos correctos a carpetas (755), solo carpetas. El dueño puede leer/escribir/ejecutar; el grupo y otros solo leer/ejecutar.
find www -type d -exec chmod 755 {} \;


# 3. Dar permisos correctos a archivos (644), solo archivos. El dueño puede leer/escribir; el grupo y otros solo leer.
# Los archivos no son ejecutables (salvo los necesarios).
find www -type f -exec chmod 644 {} \;


# 4. Dar permisos de escritura especiales solo a storage/ y bootstrap/cache/. Recursivo (todo dentro), permitir lectura y escritura al usuario (u) y al grupo (g).
chmod -R ug+rw www/storage www/bootstrap/cache


echo "Permisos corregidos con éxito"
