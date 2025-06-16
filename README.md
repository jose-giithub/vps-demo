# 🛠️ Configurar VPS desde 0 paso a paso💾
**Autor**: Jose Rodríguez  

Guía completa para montar un servidor Ubuntu con Docker, Portainer y Nginx Proxy Manager.

## Índice

- [¿Qué es este tutorial?](#que-es-este-tutorial)
- [🧰 Si quieres uno tutorial más completo lo tienes en:](#-si-quieres-uno-tutorial-mas-completo-lo-tienes-en)
- [📋 Requisitos previos](#-requisitos-previos)
- [👤 Crear nuevo usuario personal](#-crear-nuevo-usuario-personal)
- [💽 Actualiza sistema e instalar nuevas herramientas](#actualizarSistema)
- [🛡️ Seguridad](#seguridad)
- [🧼 Escaneo y limpieza de malware](#-escaneo-y-limpieza-de-malware)
- [📧 Configurar correos automáticos](#correosAutomaticos)
- [🤖 Scripts automáticos](#scriptsAutomaticos)
- [🐳 Instalar Docker](#-instalar-docker)
- [⚓ Instalar Portainer](#-instalar-portainer)
- [👮 Nginx Proxy Manager](#-nginx-proxy-manager)
- [☁️Ejemplo web de prueba](#ejemplo-web-de-prueba)
- [🔥 Configurar firewall](#-configurar-firewall)
- [💾 Backups automáticos con Duplicati](#backupsAutomaticos)
- [🕵️ GoAccess analizador de registros del servidor web](#goaccess)
- [🌳 Estructura de como tendría que quedar tu servidor](#estructuraServer)
- [🎁Contenido extra ➕➕](#contenidoExtra)
- [🚨 Comandos útiles](#comandosUtiles)
- [🔧 Solución de problemas](#-solucion-de-problemas)
- [📚 Recursos adicionales](#-recursos-adicionales)
- [🗄️ ¿Quieres una base de datos MariaDB y PhpMyAdmin?](#️database)
- [📚Bibliografía y Recursos ](#bibliografia)

---

## ¿Qué es este tutorial?

Guía paso a paso en la **configuración** de tu servidor **VPS** con Ubuntu. Crear un entorno **robusto**, **seguro** y **superoptimizado** para alojar aplicaciones, **incluyendo** la instalación de **Docker** 🐳 y **Portainer** ⚓ para la gestión de contenedores, y **Nginx Proxy Manager** 👮 para la configuración de dominios y certificados SSL. Además, el tutorial cubre la **automatización** de **tareas de seguridad** 🛡️ y **mantenimiento** 🧹 con scripts, la implementación de backups automáticos 💾 con **Duplicati**, y la integración de **GoAccess** 📈 para el análisis las estadísticas principales. Al finalizar, tendrás un servidor preparado, seguro y optimizado para tus proyectos. ¡Listo para desplegar tus webs! 🚀🌐

---
## 🧰 Si quieres uno tutorial mas completo lo tienes en: 
🔗[Configurar VPS desde 0 paso a paso, tutorial Drive:](https://docs.google.com/document/d/1RMoX8kUR3lRntgdGNtjpnFPkNULrNoSefXUzDBEabOE/edit?usp=sharing)

## Redes sociales 🌐


**Portfolio**🔗[Enlace portfolio:](https://portfolio.jose-rodriguez-blanco.es)
**LinkedIn**🔗[Enlace LinkedIn:](https://www.linkedin.com/in/joseperfil/)
**GitHub**🔗[Enlace GitHub:](https://github.com/jose-giithub)

******
----
******

## 📋 Requisitos previos

- ✅ Tener contratado un servidor VPS
- ✅ Acceso root y su contraseña
- ✅ Sistema operativo basado en Linux, en mi caso tengo un Ubuntu 24.04 LTS
- ✅ Dominio y subdominios configurados
- ✅ IP pública del servidor

******
----
******


## 👤 Crear nuevo usuario personal

### 1. Crear nuevo usuario
```bash
adduser tuUser
```
### 1.2 Añadir tuUser al grupo sudo 

```bash
usermod -aG sudo tuUser
```
### 1.3 Verifica que se añadió bien al grupo sudo

```bash
groups tuUser
```
### 1.4 Si todo fue correcto, iniciar sesión como el nuevo usuario

```bash
su - tuUser
```
### 1.5 🔑Permite al usuario tuUser ejecutar todos los comandos “sudo” sin contraseña.
 5. 
>Cada vez que tuUser use el comando sudo nos pedirá la contraseña de tuUser y esto es un engorro para evitarlo:

```bash
 sudo visudo
```
>🔒Nos pedirá la contraseña del nuevo usuario tuUser.

>📝 Se abre el documento, añade esto al final de este mismo.

```bash
# Permite al usuario 'tuUser' ejecutar todos los comandos sin contraseña
tuUser ALL=(ALL) NOPASSWD: ALL
```


******
----
******

## <a name="actualizarSistema">💽 Actualiza  sistema e instalar nuevas herramientas </a>

### 1. Actualiza sistema

```bash
sudo apt update && sudo apt upgrade -y
```
### 2. Instalar nuevas herramientas

1. **7zip, nano y tree**

```bash
sudo apt install p7zip-full nano tree -y
```

2. **net-tools**
> Comando ifconfig, netstat y otros.

```bash
sudo apt install net-tools -y
```
3. **nmap**
>Escaneo de puertos (para saber qué está abierto o cerrado).

```bash
sudo apt install nmap 
```
4. **lsof**
>Ver qué procesos están usando archivos o puertos.

```bash
sudo apt install lsof 
```

******
----
******


## <a name="seguridad">🛡️Seguridad</a>

### 1. Instalar protecciones
```bash
# Firewall y protección contra ataques
sudo ufw allow OpenSSH
sudo apt install fail2ban -y
sudo systemctl enable fail2ban
sudo systemctl start fail2ban
```
#### Para ver su estado:

```bash
sudo systemctl status fail2ban
```
#### Para ver qué está protegiendo:

```bash
sudo fail2ban-client status
```
### 2. Firewall básico. Ejemplo para activar UFW y permitir solo SSH (puerto 22):

```bash
sudo ufw enable
```
### 3. Descargas seguras y verificación de paquetes

```bash
sudo apt install ca-certificates curl gnupg lsb-release -y
```
### 4. Crear htpasswd

```bash
sudo apt install apache2-utils -y
```
******
----
******
## 🧼 Escaneo y limpieza de malware

### 1. Instalar rkhunter y chkrootkit

```bash
sudo apt update
sudo apt install rkhunter chkrootkit -y
```
### 2.Ejecutar el escaneo manualmente de rkhunter

```bash
sudo rkhunter --update
sudo rkhunter --propupd    # Solo la primera vez (guarda estado actual del sistema)
sudo rkhunter --check        # Iniciar escaneo, esto puede tardar un rato,
```
#### 🔍Para ver el resumen del escaneo:

```bash
sudo cat /var/log/rkhunter.log | grep Warning:
```
### 3.  Ejecutar el escaneo manualmente de chkrootkit

```bash
sudo chkrootkit
```

### 4.🗑️ Borrar archivos temporales y limpieza general

```bash
sudo apt autoremove -y
sudo apt autoclean
sudo journalctl --vacuum-time=7d  #Esto borrará los logs del sistema de más de 7 días (¡sin romper nada!).
```

******
----
******
## <a name="correosAutomaticos">📧 Configurar correos automáticos</a> 

>> ***🚨Super importante:***
> **Nota**: Necesitas crear una contraseña de aplicación en Gmail para usar *msmtp*.

> **🛠️ ¿Cómo crear una contraseña de aplicaciones en Gmail?**

📽️[Enlace tutorial YouTube:](https://www.youtube.com/watch?v=xnbGakU7vhE&ab_channel=IntegraConsorcio)
🔗[Enlace para crear contraseña para aplicaciones:](https://myaccount.google.com/apppasswords?pli=1&rapt=AEjHL4MHL_5C54kRNxmAyPqkCc11cIS6PaQUadf10jiV0NpqTOVls3mv0scETT8lfjeF3LkRqx6fEXGmxSkQryd4Rk8ODLijJ8l7OuniUnNRxUDbhqPd2y8)

### 1. Instalar cliente de correo

```bash
sudo apt install -y msmtp msmtp-mta
```
ℹ️❗Te mostrará esta ventana: 
“Quieres que msmtp se instale con su perfil de AppArmor activado” es una capa de seguridad, en mi caso le daré a ***no***, pues puede dar problemas difíciles de depurar en el futuro y en este caso es un servicio muy sencillo.


### 2. Configurar Gmail
>Crear archivo de configuración:

```bash
nano ~/.msmtprc
```

Contenido del archivo:

```
defaults
auth on
tls on
tls_trust_file /etc/ssl/certs/ca-certificates.crt
logfile ~/.msmtp.log

account default
host smtp.gmail.com
port 587
from tu-email@gmail.com
user tu-email@gmail.com
password TU_CONTRASEÑA_DE_APLICACION
```

### 3. 🔐Proteger el archivo .msmtprc

```bash
chmod 600 ~/.msmtprc
```
### 4. 🔓 Validar que el puerto esté abierto en tu servidor

>Para Gmail se usa puerto **587** con TLS.

```bash
telnet smtp.gmail.com 587
```
>❗Entrarás en la terminal Telnet. Para salir 🔚, presiona:

```bash
# Presiona las teclas Ctrl + ]
```

### 5. Probar envío
```bash
echo "Mensaje de prueba" | mail -s "Prueba desde servidor" tu-email@gmail.com
```
>Verifica que llegó en tu bandeja de entrada de Gmail

### 6. 📧 Instalar *mailutils* para la gestionar el correo electrónico en la consola.


**1. Instala *mailutils***

```bash
sudo apt install mailutils
```

**2. 🕵️ Verificar que msmtp ya está vinculado como sendmail con un enlace simbólico que apunte a (ls -l /usr/sbin/ )**

```bash
ls -l /usr/sbin/sendmail 
```
>✔️ Si ves esto:

```bash
/usr/sbin/sendmail -> ../bin/msmtp
```
👍…entonces ya está listo. 


>👎Si no, puedes enlazarlo manualmente:

```bash
sudo mv /usr/sbin/sendmail /usr/sbin/sendmail.bak
sudo ln -s /usr/bin/msmtp /usr/sbin/sendmail
```

**3. 🖋️ Copiar la configuración de msmtp para el usuario root .**

```bash
sudo cp /home/tuUser/.msmtprc /root/.msmtprc
sudo chmod 600 /root/.msmtprc
```

**4. 🕵️Valida que funcione.**

- 1. Desde la terminal nos mandaremos un correo a nuestra cuenta de Gmail.

```bash
echo "¡Hola tuUser! Esto es una prueba usando msmtp como sendmail." | sudo sendmail ejemplo@gmail.com
```
- 2. 🧪Revisa tu correo en teoría tendría que haberte llegado este correo.


**5. 🖋️Añadir *MAILTO* en el crontab de root**

```bash
sudo crontab -e
```
> Añade esto en la primera linea de tu documento cron
```bash
# m h  dom mon dow   command  <<<<------ ⚠️esta línea ya existe, añade justo debajo de esta, que seria la primera linea de edición del documento⚠️

# Si el script falla antes de generar cualquier log, cron te mandará el stderr al mail
MAILTO="ejemplo@gmail.com"
# Enviar correo cada 2 minutos para probar
*/2 * * * * echo "¡Hola tuUser! Esto es una prueba desde cron."
```

> Espera 2 minutos y verifica tu Gmail, si ves el correo ¡todo funciona! 🎉

******
----
******

## <a name="scriptsAutomaticos">🤖 Scripts automáticos </a>          

### 🧼 Script de limpieza diaria

>Crear un archivo que se ejecutará automáticamente todas las semanas para automatizar la limpieza del servidor, enviar notificaciones por correo (éxito o error), y gestionar los logs de forma rotativa.

El script guardará los logs de cada ejecución en la ruta */home/tuUser/scripts/logs/* con un formato de nombre diario (ej. limpieza_seguridad_diaria_2025-06-05.log), manteniendo solo los últimos 7 días.


- 🧹 **Limpieza del servidor diaria**
- 📧 **Notificaciones por correo (éxito/error)**
- 📁 **Logs diarios con rotación automática (7 días)**



1. **Crear directorio y archivo**:

```bash
mkdir -p /home/tuUser/scripts
nano /home/tuUser/scripts/limpieza_seguridad_diaria.sh
```

2. **Contenido del script**:

```bash
#!/bin/bash
# Script para limpieza y seguridad diaria (ejecutar como root)
# Guarda logs diarios, mantiene solo los últimos 7 días, y envía notificaciones inteligentes.

DESTINATARIO="ejemplo@gmail.com"
# Ruta del .msmtprc explícitamente, para que funcione con cron/root
MSMTP_CONFIG="/home/tuUser/.msmtprc"
BASE_DIR="/home/tuUser/scripts"
LOG_DIR="$BASE_DIR/logs"
FECHA_HOY=$(date +%F) # Ej: 2025-06-09
LOG_FILE="$LOG_DIR/limpieza_seguridad_diaria_$FECHA_HOY.log"

# --- INICIO DE LA EJECUCIÓN ---
# Verifico si msmtp está disponible y la ruta es correcta
if [ ! -x "$(command -v msmtp)" ]; then
    echo "❌ ERROR: El comando 'msmtp' no está instalado o no es ejecutable."
    exit 1
fi


# Asegura que existe el directorio de logs
mkdir -p "$LOG_DIR"

# Borra los logs más antiguos, dejando solo los últimos 7
find "$LOG_DIR" -type f -name 'limpieza_seguridad_diaria*.log' | sort | head -n -7 | xargs -r rm

# Captura todo lo que se imprime en el log Y en la consola
exec > >(tee -a "$LOG_FILE") 2>&1

echo "🕒 Fecha de inicio: $(date)"
echo "🔐 Iniciando escaneo de seguridad..."

# --- ARCHIVOS TEMPORALES ---
# 1. Un único archivo para acumular TODAS las advertencias que encontremos.
WARNINGS_FILE=$(mktemp /tmp/security_warnings.XXXXXX)
# 2. Archivos temporales para logs de cada herramienta
RKHUNTER_LOG=$(mktemp /tmp/rkhunter_log.XXXXXX)
CHKROOTKIT_LOG=$(mktemp /tmp/chkrootkit_log.XXXXXX)

# ------------------ RKHUNTER -------------------
echo "📥 Actualizando RKHunter..."
# Simplificado: si falla, el error se registrará en el log principal gracias a 'tee'
if ! rkhunter --update > /dev/null 2>&1; then
    echo "❌ ERROR: Falló la actualización de RKHunter. Comprueba /var/log/rkhunter/rkhunter.log"
fi

echo "📦 Guardando propiedades actuales del sistema..."
if ! rkhunter --propupd -q; then
    echo "⚠️ ERROR: Falló guardar propiedades de archivos (propupd)"
fi

echo "🔎 Escaneando con RKHunter..."
rkhunter --check --sk --nocolors > "$RKHUNTER_LOG" 2>&1
# Mostramos las advertencias en el log principal para que queden registradas
grep -E "Warning|Possible rootkits" "$RKHUNTER_LOG" || echo "✔️ Sin advertencias de RKHunter."
# Y las añadimos a nuestro archivo centralizado de advertencias
grep -E "Warning|Possible rootkits" "$RKHUNTER_LOG" >> "$WARNINGS_FILE"

# ------------------ CHKROOTKIT -------------------
echo "🔍 Ejecutando chkrootkit..."
# Ejecutamos chkrootkit en modo silencioso para evitar los "not found/infected"
chkrootkit -q > "$CHKROOTKIT_LOG" 2>&1
# Mostramos el resultado en el log principal
cat "$CHKROOTKIT_LOG"
# Añadimos solo las líneas que contienen "WARNING" a nuestro archivo centralizado
grep "WARNING" "$CHKROOTKIT_LOG" >> "$WARNINGS_FILE"

# ------------------ LIMPIEZA -------------------
echo "🧹 Limpiando sistema (paquetes y cachés)..."
apt-get autoremove -y > /dev/null
apt-get autoclean -y > /dev/null

echo "🧹 Limpiando /tmp y /var/tmp (archivos con más de 7 días)..."
find /tmp -type f -atime +7 -delete
find /var/tmp -type f -atime +7 -delete

# ------------------ LOGS -------------------
echo "🧻 Borrando logs del sistema (más de 7 días)..."
journalctl --vacuum-time=7d

# ------------------ LÓGICA DE NOTIFICACIÓN -------------------
echo "📊 Analizando resultados para notificación..."

# 3. Patrón de expresiones regulares para ignorar todas las advertencias conocidas y seguras.
#    AÑADIMOS los encabezados de 'chkrootkit' y el resumen de 'rkhunter' para un silencio total.
IGNORE_PATTERN=$(cat <<'EOP'
\.gitignore
\.htaccess
\.htpasswd
\.document
\.build-id
PACKET SNIFFER
SSH root access
hidden files and directories
Possible rootkits: 0
WARNING: The following suspicious files and directories were found:
WARNING: Output from ifpromisc:
EOP
)

# 4. Filtramos el archivo de advertencias: buscamos cualquier advertencia y le quitamos las que conocemos.
#    El resultado solo contendrá advertencias NUEVAS o DESCONOCIDAS.
ADVERTENCIAS_REALES=$(grep -v -E "$IGNORE_PATTERN" "$WARNINGS_FILE")


# 5. Verificamos si, después de filtrar, queda alguna advertencia real.
if [ -n "$ADVERTENCIAS_REALES" ]; then
    # Si la variable NO está vacía, es que hay una advertencia real.
    echo "🚨 ¡ADVERTENCIA REAL DETECTADA! Enviando correo de alerta."
    (
        echo "Subject:⚠️ [Limpieza diaria del servidor] Se detectaron NUEVAS advertencias"
        echo
        echo "Revisa el log del día $FECHA_HOY. Se encontraron las siguientes advertencias no reconocidas:"
        echo "------------------------------------------------------------------"
        echo "$ADVERTENCIAS_REALES"
        echo "------------------------------------------------------------------"
        echo "Log completo en: $LOG_FILE"
    ) | msmtp --file="$MSMTP_CONFIG" "$DESTINATARIO"
else
    # Si la variable está vacía, todo está en orden.
    echo "✔️ No se encontraron advertencias nuevas. Enviando correo de éxito."
    (
        echo "Subject: ✅ [Limpieza diaria del servidor] Limpieza de sistema realizada sin incidentes"
        echo
        echo "La limpieza y el escaneo de seguridad se llevaron a cabo satisfactoriamente el $FECHA_HOY."
        echo "Todas las advertencias detectadas fueron falsos positivos conocidos."
    ) | msmtp --file="$MSMTP_CONFIG" "$DESTINATARIO"
fi


# ------------------ FINAL -------------------
echo "✅ Escaneo completado correctamente a las: $(date)"
echo "---Fin---"

# Elimina los archivos temporales
rm -f "$WARNINGS_FILE" "$RKHUNTER_LOG" "$CHKROOTKIT_LOG"

exit 0

```
💾 Presiona `Ctrl + X` para salir y guardar. 

3. **Hacer ejecutable**:

```bash
chmod +x /home/tuUser/scripts/limpieza_seguridad_diaria.sh
```

4. **📝Modificar el archivo rkhunter.conf**

  1. **Entra en el archivo *rkhunter.conf* ⚠️ (con sudo)**

```bash
 sudo nano /etc/rkhunter.conf
```
  2. **Busca esta línea: *WEB_CMD="/bin/false" y comentala con #***

```bash
 #WEB_CMD="/bin/false"
  ```
  3. **Busca esta línea: *UPDATE_MIRRORS* y *MIRRORS_MODE=* modifícalas por:**

  ```bash
  UPDATE_MIRRORS=1
  MIRRORS_MODE=0
  ```
  4. **Añade esta línea al final del documento**

  ```bash
  UPDATE_METHOD=1
  ```

  💾 Presiona `Ctrl + X` para salir y guardar. 

  >🕵️‍♂️ Validar que se actualiza correctamente ejecutándolo manualmente con:

```bash
sudo rkhunter --update
```


5. **🚀 Validar que funciona ejecutándolo manualmente *⚠️con sudo***


```bash
sudo /home/tuUser/scripts/limpieza_seguridad_diaria.sh
```

6. **programar la ejecución automática**

>Hacer que el script se ejecute automáticamente todos los días a las 4:20 de la madrugada

```bash
sudo crontab -e
```
⚠️ la primera vez que usas crontab con el usuario root aparecer esto

```bash
To change later, run 'select-editor'. 
1. /bin/nano <---- easiest 
2. /usr/bin/vim.basic 
3. /usr/bin/vim.tiny 
4. /bin/ed
```

ℹ️Ese mensaje aparece porque el sistema quiere saber qué editor de texto prefieres para escribir el archivo de tareas programadas (crontab).

Selecciona la opción:

```bash
1. /bin/nano        <---- easiest
```

>Después de esto, se abrirá un archivo, tienes que añadir el código:

```bash
# Si el script falla antes de generar cualquier log, cron te mandará el stderr al mail
MAILTO="tu_correo_aqui@gmail.com"

# Comando para que se ejecute el archivo .sh que realizara un escaneo y limpiez>
20 4 * * * bash /home/tuUser/scripts/limpieza_seguridad_diaria.sh >> /home/tuUser/scripts/logs/cron_debug.log 2>&1
```
💾 Presiona `Ctrl + X` para salir y guardar. 

>🕵️Cuando lo hayas hecho, puedes comprobar que está programado con:

```bash
sudo crontab -l
```
  
7. **🚀 Validar que funciona el script ejecutándolo manualmente**:


```bash
sudo bash /home/tuUser/scripts/limpieza_seguridad_diaria.sh
```
8. **🔎Ver logs**:

```bash
# Modifica la fecha por la fecha de ejecución:
cat /home/tuUser/scripts/logs/limpieza_seguridad_diaria_$(date +%F).log
```

8. **🚀 Si hasta ahora todo ha funcionado. Programa una ejecución cerca de la hora que tienes para testear el sistema.**

>Si algo falla puedes validar si tienes algo en la bandeja del correo interno del servidor


```bash
sudo mail
```
>Valida el log que se crea al ejecutar el con:

```bash
cat scripts/logs/cron_debug.log 
```


******
----
******

### Script de actualización semanal

>Crear un archivo que se ejecutará automáticamente todas las semanas para actualizar el servidor, enviar notificaciones por correo (éxito o error), y gestionar los logs de forma rotativa, guardando solo los de 7 días de antigüedad.

El script guardará los logs de cada ejecución en la ruta */home/tuUser/scripts/logs/* con un formato de nombre diario (ej. actualizar_sistema_2025-06-05.log).

- ⚙️**Actualización de todos los paquetes y aplicaciones del sistema**
- 📧 **Notificaciones por correo (éxito/error)**
- 📁 **Logs diarios con rotación automática (7 días)**
- 🧹 **Limpieza automática de logs antiguos**


1. **Crear script**:


```bash
nano /home/tuUser/scripts/actualizarSistema.sh
```

2. **Contenido**:

```bash
#!/bin/bash

# Script para actualizar el servidor automáticamente
# Notifica por correo si hay errores o si se completa correctamente
# Rotación de logs, solo se guardan 7 días de logs

DESTINATARIO="ejemplo@gmail.com"
#Ruta del .msmtprc explícitamente, esto obliga a msmtp a usar tu configuración aunque el script lo ejecute root,
MSMTP_CONFIG="/home/tuUser/.msmtprc"
LOG_DIR="/home/tuUser/scripts/logs" # Ubicación de los archivos .log
FECHA_HOY=$(date +%F)  # formato: 2025-06-05
LOG_FILE="$LOG_DIR/actualizar_sistema_$FECHA_HOY.log"  # formato: del log actualizar_sistema_2025-06-05.log

# Asegurarse de que el directorio de logs existe ANTES de hacer el mkdir para el log del día
mkdir -p "$LOG_DIR"

# Limitar a los últimos 7 logs (los más recientes)
# Nota: La lógica de rotación debe ejecutarse ANTES de crear o escribir en el LOG_FILE del día actual
find "$LOG_DIR" -type f -name 'actualizar_sistema*.log' | sort | head -n -7 | xargs -r rm

# --- Iniciar la captura de la salida a un archivo de log y a la consola ---
# Todas las líneas siguientes se enviarán tanto al LOG_FILE como a la salida estándar
# `exec > >(tee -a "$LOG_FILE") 2>&1` redirige stdout y stderr al tee, que a su vez lo envía al archivo y a la consola.
# Esto debe ir al principio del script, después de definir LOG_FILE, para capturar toda la salida.
exec > >(tee -a "$LOG_FILE") 2>&1

echo "📦 Actualizando lista de paquetes..."
echo "🕒 Fecha de inicio: $(date)" # Muestra la fecha de inicio en el log y en la consola

if ! apt-get update; then
    echo "❌ ERROR: Fallo actualización (apt-get update)."
    # Envía el correo con el error, incluyendo el contenido del log hasta ese punto
    echo -e "Subject: ❌ ERROR: Fallo actualización (apt-get update)\n\nFalló la actualización de paquetes. Ver log adjunto." | msmtp --file="$MSMTP_CONFIG" "$DESTINATARIO"
    exit 1
fi

echo "⬆️ Actualizando paquetes instalados..."
if ! apt-get upgrade -y; then
    echo "❌ ERROR: Fallo actualización (apt-get upgrade)."
    # Envía el correo con el error, incluyendo el contenido del log hasta ese punto
    echo -e "Subject: ❌ ERROR: Fallo actualización (apt-get upgrade)\n\nFalló la actualización de paquetes instalados. Ver log adjunto." | msmtp --file="$MSMTP_CONFIG" "$DESTINATARIO"
    exit 1
fi

echo "🧹 Limpiando paquetes innecesarios..."
apt-get autoremove -y
apt-get autoclean

echo "---Fin de la actualización del sistema---"

# Notificación de éxito (esta notificación se envía por correo, el contenido de la salida de apt-get ya está en el log)
echo -e "Subject: ✅ Sistema actualizado\n\nEl sistema se actualizó correctamente el $(date)" | msmtp --file="$MSMTP_CONFIG" "$DESTINATARIO"

exit 0 # Asegura una salida exitosa si todo va bien
```

3. **Hacer ejecutable y programar**:
>Hacer que el script se ejecute automáticamente cada lunes a las 3:00 AM:

```bash
chmod +x /home/tuUser/scripts/actualizarSistema.sh
sudo crontab -e
# Añadir línea (ejecuta cada lunes a las 3:00 AM):
0 3 * * 1 /home/tuUser/scripts/actualizarSistema.sh
```
4. **🚀 Validar que funciona ejecutándolo manualmente ⚠️ (con sudo)**:

```bash
sudo bash /home/tuUser/scripts/actualizarSistema.sh
```
4. **🔎 Ver el resultado:**:

```bash
cat /home/tuUser/scripts/logs/actualizar_sistema_$(date +%F).log
```
> 🧐Verifica en tu correo si recibiste el e-mail.

> 👀Podrás ver los logs diarios en **(/home/tuUser/scripts/logs)**

******
----
******

## 🐳 Instalar Docker

### 1. Preparar repositorio

```bash
sudo apt update
sudo apt install ca-certificates curl gnupg lsb-release -y
#Creo el directorio keyrings
sudo mkdir -p /etc/apt/keyrings
# Descarga la clave pública GPG de Docker de su sitio web de forma silenciosa  y guarda esa clave binaria en el archivo /etc/apt/keyrings/docker.gpg
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
```

### 2. Añadir repositorio oficial

```bash
echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
https://download.docker.com/linux/ubuntu \
$(lsb_release -cs) stable" | \
sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

### 3. Instalar Docker

```bash
sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
```

### 4. Configurar usuario, añadimos nuestro user al grupo docker

```bash
sudo usermod -aG docker tuUser
sudo reboot
```

1. **🔴 Muy importante: debes cerrar sesión y volver a entrar (o reiniciar) para que el usuario se añada al grupo correctamente.**

```bash
sudo reboot
```
2.**Una vez reiniciado el sistema, comprobar que estás en el grupo con:**

```bash
groups
```

### 5. Verificar instalación
```bash
docker run hello-world
```

******
----
******

## ⚓ Instalar Portainer

### 1. Crear estructura

```bash
mkdir -p /home/tuUser/servers/portainer
cd /home/tuUser/servers/portainer
```

### 2. Crear docker-compose.yaml
```bash
nano docker-compose.yaml
```

Contenido:
```yaml
services:
  portainer:
    image: portainer/portainer-ce:latest
    ports:
      - 9443:9443
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - portainer_data:/data
    restart: unless-stopped

volumes:
  portainer_data:
```

### 3. Levantar contenedor
```bash
docker compose up -d
```

### 4. 👀Validar que funciona

Navegar a: `https://IP-DEL-SERVIDOR:9443`


******
----
******

## 👮 Nginx Proxy Manager

### 1. Crear estructura
```bash
mkdir -p /home/tuUser/servers/nginx
cd /home/tuUser/servers/nginx
```

### 2. Crear docker-compose.yaml
```bash
nano docker-compose.yaml
```

Contenido:
```yaml
services:
  app:
    image: 'jc21/nginx-proxy-manager:latest'
    container_name: nginxproxymanager
    restart: unless-stopped
    ports:
      - '80:80'
      - '81:81'
      - '443:443'
    volumes:
      - ./data:/data
      - ./letsencrypt:/etc/letsencrypt
    networks:
      - proxiable

networks:
  proxiable:
    name: proxiable
```

### 3. Levantar contenedor

```bash
docker compose up -d
```

### 4.🔓 Configurar acceso inicial

- URL: `http://IP-DEL-SERVIDOR:81`
<!-- Cuando entras por primera vez estas son las credenciales -->
- Usuario inicial: `admin@example.com`
- Contraseña inicial: `changeme`

*** ⚠️Después de acceder te obligará a modificarlas**


### 5. Configurar dominio con SSL
1. Crear nuevo Proxy Host
2. Domain Names: tu-subdominio.com
3. Forward Hostname/IP: nginxproxymanager  **Definido en container_name que tenemos en el archivo *docker-compose.yaml*.**
4. Forward Port: 81 **Definido en el archivo *docker-compose.yaml*.**
5. En pestaña SSL: Request new SSL certificate


******
----
******

## Ejemplo web de prueba

### 1. Crear estructura
```bash
mkdir -p /home/tuUser/servers/testweb/www
cd /home/tuUser/servers/testweb
```

### 2. Crear docker-compose.yaml
```yaml
services:
  testweb:
    image: nginx:alpine
    container_name: testweb
    restart: unless-stopped
    volumes:
      - ./www:/usr/share/nginx/html
    expose:
      - "80"
    networks:
      - proxiable

networks:
  proxiable:
    external: true
```


### 3. Crear página de prueba
```bash
cd /home/tuUser/servers/testweb/www
nano www/index.html
```

```html
<!DOCTYPE html>
<html>
<head>
    <title>Test Web</title>
</head>
<body>
    <h1>Hola mundo desde Docker y Nginx</h1>
</body>
</html>
```

### 4. Levantar contenedor
```bash
docker compose up -d
```

### 5. Verificar comunicación entre contenedores
```bash
# Verificar que ambos contenedores están en la misma red
docker network inspect proxiable
```

Busca que aparezcan los contenedores esperados:
- `"Name": "testweb"`
- `"Name": "nginxproxymanager"`

Esto confirma que ambos están en la misma red Docker y se pueden comunicar por nombre de contenedor.

### 6. 🛠️Configurar dominio con SSL en Nginx Proxy Manager

1. **Acceder a Nginx Proxy Manager**: `http://IP-DEL-SERVIDOR:81`

2. **Crear nuevo Proxy Host**:
   - **Domain Names**: tu-subdominio-web.com (el subdominio para tu web de prueba)
   - **Forward Hostname/IP**: `testweb` (nombre del contenedor)
   - **Forward Port**: `80`
   - **Scheme**: http
   - **Pestaña *Block Common Exploits*** | ✅ Activado    

   3. **Configuración SSL (Opcional):**
   - Pestaña **"SSL"**
   - ***Dejar marcada las pestañas ***
   - ✅ **SSL Certificate**
   - ✅ **Force SSL**
   - ✅ **HTTP/2 Support**
   - **Save**

4. **Verificar acceso**:
   - HTTP: `http://tu-subdominio-web.com` (redirigirá a HTTPS)
   - HTTPS: `https://tu-subdominio-web.com`



## 🔥 Configurar firewall

```bash
# Abrir puertos necesarios
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# Verificar estado del firewall
sudo ufw status
```

### Verificar conectividad del dominio

**Desde el servidor:**
```bash
ping tu-dominio.com
```

**Desde tu computadora local:**

```bash
ping tu-dominio.com
```

Ambos comandos deben mostrar respuesta desde la IP de tu servidor, confirmando que el DNS está configurado correctamente.


******
----
******

## <a name="backupsAutomaticos">💾 Backups automáticos con Duplicati </a>

🔗[Info del contenedor:](https://hub.docker.com/r/linuxserver/duplicati)

### 1. Crear estructura

```bash
mkdir -p /home/tuUser/servers/duplicati
cd /home/tuUser/servers/duplicati
```

### 2. Crear docker-compose.yaml

```yaml
services:
  duplicati:
    image: duplicati/duplicati:latest
    container_name: duplicati
    volumes:
      - ./duplicati-data:/data
      - /home/tuUser:/source # Carpeta origen (lo que quieres guardar)
      - ./backups:/backups  # Carpeta destino de backups  en el mismo servidor si así lo deseamos
    environment:
      - TZ=Europe/Madrid
      - SETTINGS_ENCRYPTION_KEY=${SETTINGS_ENCRYPTION_KEY}
      - DUPLICATI_WEBSERVICE_PASSWORD=${DUPLICATI_WEBSERVICE_PASSWORD}
    ports:
      - 8200:8200
    restart: unless-stopped
```

### 3. Crear archivo de variables de entorno

```bash
nano .env
```

```bash
TZ=Europe/Madrid
#❗ clave de cifrado para su base de datos de configuración tiene que tener 32 de longitud
SETTINGS_ENCRYPTION_KEY=tu_clave_de_32_caracteres_aqui
#contraseña de la interfaz web
DUPLICATI_WEBSERVICE_PASSWORD=tu_contraseña_segura
```

### 4. Proteger archivo de configuración
```bash
chmod 600 .env
```

### 5. Levantar contenedor
```bash
docker compose up -d
```

### 6. Obtener token inicial
```bash
docker logs duplicati
```
> guarda el toquen que te muestra

### 7. Acceder

Navegar a: `http://IP-DEL-SERVIDOR:8200`

>Nos pedirá el token, pegamos el token guardado en el paso 6.
Al entrar por primera vez nos pedirá una nueva contraseña, la ponemos y la guardamos bien que no se pierda.

## ℹ️Como crear una copia de backup automático con Duplicati

🔗[Link tutorial YouTube:](https://www.youtube.com/watch?v=hoauNQsyer8&t=103s&ab_channel=Unlocoysutecnolog%C3%ADa)



******
----
******



## <a name="goaccess">🕵️GoAccess analizador de registros del servidor web</a>

>Tutorial completo de configuración paso a paso usando Docker, almacenamiento rotativo y estadísticas web.

🔗[Link tutorial GitHab:](https://github.com/jose-giithub/vps-demo/blob/main/servers/goAccess/README.md)


******
----
******

## <a name="estructuraServer">🌳Estructura de como tendria que quedar tus servidor </a>  

*** Estrucutra resumida desde */home/tuUser* ***
```text
📂vps-demo/
├──📂 scripts
│   ├── 📄actualizarSistema.sh
│   ├──📄 limpieza_seguridad_diaria.sh
│   ├── 📄run_goaccess_report.sh
│   └── 📂logs
│          ├── 📄actualizar_sistema_2025-06-05.log
│          └── 📄limpieza_seguridad_diaria_2025-06-05.log
└── 📂servers
    ├──📂 duplicati
    │   ├── 📄docker-compose.yaml
    │   ├── 📄.env
    │   ├──📂 backups
    │   └── 📂duplicati-data
    ├──📂 goAccess
    │   ├──📄docker-compose.yaml
    │   ├── 📄 generate-report.sh
    │   ├── 📄 goaccess.conf
    │   ├── 📄 htpasswd
    │   ├──  📄nginx.conf
    │   ├── 📂logs
    │   └── 📂reports
    │       ├──📄 info.html
    │       ├──📄 index.html
    │       ├── 📄last_update.txt
    │       ├── 📂data
    │       └── 📂logs
    ├── 📂nginx
    │   ├── 📄docker-compose.yaml
    │   ├──📂 data
    │   │   ├── 📂logs
    │   │   └──📂 nginx
    │   └──📂 letsencrypt
    ├── 📂portainer
    │   ├── 📄docker-compose.yaml
    ├──📂 testweb
           ├─ docker-compose.yaml
           └── 📂www
                  └── 📄index.html
```


## <a name="contenidoExtra">🎁Contenido extra ➕➕</a>

### 📊 Monitoreo con crontab 

Verificar tareas programadas:
```bash
sudo crontab -l
```

Ver logs de sistema:
```bash
# Ver logs de actualización
cat /home/tuUser/scripts/logs/actualizar_sistema_$(date +%F).log

# Ver logs de limpieza
cat /home/tuUser/scripts/logs/limpieza_seguridad_diaria_$(date +%F).log

```

### <a name="database">🗄️ Base de datos MariaDB y PhpMyAdmin</a>

**🗄️En tu proyecto ¿Te gustaría añadir una base de datos segura y Dockerizada? Aqui tienes el tutorial**

>Montar una base de datos SQL para nuestro servidor usando MariaDB y para manipularla una interfaz web PhpMyAdmin con usuario y contraseña.

- Documento Drive

🔗[Base de datos MariaDB e interface web PhpMyAdmin Dockerizado, tutorial Drive:](https://docs.google.com/document/d/1iteWeHyYgD4lyjB1zA_IN_j3bb_SpFukxwEdetI4Eo8/edit?usp=sharing)

- Tutorial en GhiHab

🔗[Base de datos MariaDB e interface web PhpMyAdmin Dockerizado, tutorial GitHab:](https://github.com/jose-giithub/vps-demo/tree/main/servers/database)

******
----
******


## <a name="comandosUtiles">🚨 Comandos útiles</a>

### Docker
```bash
# Ver contenedores activos
docker ps

# Ver todos los contenedores
docker ps -a

# Ver redes
docker network ls

# Inspeccionar red
docker network inspect proxiable

# Ver logs de contenedor
docker logs nombre-contenedor

# Reiniciar contenedor
docker restart nombre-contenedor
```
******
----
******

### 📊 Monitoreo del sistema
```bash
# Ver uso de disco
df -h

# Ver procesos
htop

# Ver puertos abiertos
sudo netstat -tulpn

# Ver servicios activos
sudo systemctl list-units --type=service --state=active
```

******
----
******

## 🔧 Solución de problemas

### Si los contenedores no se comunican:
```bash
# Verificar que están en la misma red
docker network inspect proxiable
```

### Si falla el firewall:
```bash
# Reiniciar UFW
sudo ufw --force reset
sudo ufw enable
sudo ufw allow OpenSSH
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
```

### Si fallan los scripts automáticos:
```bash
# Verificar permisos
ls -la /home/tuUser/scripts/
chmod +x /home/tuUser/scripts/*.sh
```
******
----
******

## 📚 Recursos adicionales

- [Docker Documentation](https://docs.docker.com/)
- [Nginx Proxy Manager](https://nginxproxymanager.com/)
- [Portainer Documentation](https://docs.portainer.io/)
- [Duplicati Manual](https://duplicati.readthedocs.io/)

---

## <a name="bibliografia">📚Bibliografia Bibliografía y Recursos🔗</a>

- **YouTube** 
- **GitHub** 
- **Docker Docs** 
- **Docker Hub Container Image Library** 
- **Solvetic** - Solución a los problemas informáticos 
- **GoAccess** - Visual Web Log Analyzer 
- **EmojiTerra** 🌍 - Emojis Copiar & Pegar 😄

---

> **Nota de seguridad**: Cambia todas las contraseñas y claves de ejemplo por valores seguros antes de usar en producción.