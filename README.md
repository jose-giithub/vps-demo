# 🛠️ Configurar VPS desde 0 paso a paso💾
**Autor**: Jose Rodríguez  

Guía completa para montar un servidor Ubuntu con Docker, Portainer y Nginx Proxy Manager.
## 🧰 Si quieres uno tutorial mas completo lo tienes en: 
🔗[Enlace tutorial Drive:](https://docs.google.com/document/d/1RMoX8kUR3lRntgdGNtjpnFPkNULrNoSefXUzDBEabOE/edit?usp=sharing)

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
- ✅ Sistema operativo basado en Linux  en mi caso tengo un Ubuntu 24.04 LTS
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

******
----
******

## 💽 Actualiza  sistema e instalar nuevas herramientas

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
>> Comando ifconfig, netstat y otros.

```bash
sudo apt install net-tools -y
```
3. **nmap**
>>Escaneo de puertos (para saber qué está abierto o cerrado).

```bash
sudo apt install nmap 
```
3. **lsof**
>>Ver qué procesos están usando archivos o puertos.

```bash
sudo apt install lsof 
```

******
----
******


## 🛡️ Seguridad

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

## 🤖 Scripts automáticos

### 🧼 Script de limpieza diaria

1. **Crear directorio y archivo**:
```bash
mkdir -p /home/tuUser/scripts
nano /home/tuUser/scripts/limpieza_seguridad_diaria.sh
```

2. **Contenido del script**:
```bash
#!/bin/bash
# Script de limpieza y seguridad diaria

BASE_DIR="/home/tuUser/scripts"
LOG_DIR="$BASE_DIR/logs"
FECHA_HOY=$(date +%F)
LOG_FILE="$LOG_DIR/limpieza_seguridad_diaria_$FECHA_HOY.log"

mkdir -p "$LOG_DIR"

# Mantener solo los últimos 7 logs
find "$LOG_DIR" -type f -name 'limpieza_seguridad_diaria*.log' | sort | head -n -7 | xargs -r rm

echo "🕒 Fecha: $(date)" > "$LOG_FILE"
echo "🔐 Iniciando escaneo de seguridad..." >> "$LOG_FILE"

# Actualizar RKHunter
echo "📥 Actualizando RKHunter..." >> "$LOG_FILE"
sudo rkhunter --update >> /dev/null 2>&1
sudo rkhunter --propupd -q

# Escanear con RKHunter
echo "🔎 Analizando con RKHunter..." >> "$LOG_FILE"
sudo rkhunter --check --sk --nocolors > /tmp/rkhunter_check.txt 2>&1
grep -E "Warning|Possible rootkits" /tmp/rkhunter_check.txt >> "$LOG_FILE" || echo "✔ Sin advertencias de RKHunter." >> "$LOG_FILE"

# Escanear con chkrootkit
echo "🔍 Ejecutando chkrootkit..." >> "$LOG_FILE"
sudo chkrootkit | grep -v "not found" | grep -v "not infected" >> "$LOG_FILE"

# Limpieza del sistema
echo "🧹 Limpiando sistema..." >> "$LOG_FILE"
sudo apt autoremove -y >> /dev/null
sudo apt autoclean >> /dev/null
sudo journalctl --vacuum-time=7d >> "$LOG_FILE"

echo "✅ Escaneo completado correctamente." >> "$LOG_FILE"
```

3. **Hacer ejecutable y programar**:

```bash
chmod +x /home/tuUser/scripts/limpieza_seguridad_diaria.sh
crontab -e
```
4. **🚀 Validar que funciona ejecutándolo manualmente**:

```bash
bash /ruta/completa/limpieza_seguridad_diaria.sh
```
5. **🔎Ver logs**:

```bash
# Modifica la fecha por la fecha de ejecución:
cat /home/tuUser/scripts/logs/limpieza_seguridad_diaria_2025-06-04.log
```

>>>Hacer que el script se ejecute automáticamente todos los días a las 4:20 de la madrugada (esta hora está libre y nada más se estará ejecutando con cron):

**Dentro del documento añade este código**
```bash
# Añadir línea:
20 4 * * * /home/tuUser/scripts/limpieza_seguridad_diaria.sh

```
*********

### Script de actualización semanal

1. **Crear script básico**:

```bash
nano /home/tuUser/scripts/actualizarSistema.sh
```

2. **Contenido básico**:

```bash
#!/bin/bash

echo "📦 Actualizando lista de paquetes..."
sudo apt update

echo "⬆️ Actualizando paquetes instalados..."
sudo apt upgrade -y

echo "🧹 Limpiando paquetes innecesarios..."
sudo apt autoremove -y
sudo apt autoclean
echo "✅ Sistema actualizado correctamente el $(date)"
```

3. **Hacer ejecutable y programar**:
>>>Hacer que el script se ejecute automáticamente cada lunes a las 3:00 AM:

```bash
chmod +x /home/tuUser/scripts/actualizarSistema.sh
crontab -e
# Añadir línea (ejecuta cada lunes a las 3:00 AM):
0 3 * * 1 /home/tuUser/scripts/actualizarSistema.sh
```
4. **🚀 Validar que funciona ejecutándolo manualmente**:

```bash
sudo bash -c '/home/jose/scripts/actualizarSistema.sh >> /var/log/actualizarSistema.log 2>&1'
```
4. **🔎 Ver el resultado:**:

```bash
cat /var/log/actualizarSistema.log
```

******
----
******

## 📧 Configurar correos automáticos 

>> ***🚨Superimportante:***
> **Nota**: Necesitas crear una contraseña de aplicación en Gmail para usar con aplicaciones menos seguras.
> **🛠️ ¿Cómo crear una contraseña de aplicaciones en Gmail?**
🔗[Enlace tutorial YouTube:](https://www.youtube.com/watch?v=xnbGakU7vhE&ab_channel=IntegraConsorcio)
🔗[Enlace para crear contraseña para aplicaciones:](https://myaccount.google.com/apppasswords?pli=1&rapt=AEjHL4MHL_5C54kRNxmAyPqkCc11cIS6PaQUadf10jiV0NpqTOVls3mv0scETT8lfjeF3LkRqx6fEXGmxSkQryd4Rk8ODLijJ8l7OuniUnNRxUDbhqPd2y8)

### 1. Instalar cliente de correo

```bash
sudo apt install -y msmtp msmtp-mta
```
>>>ℹ️❗Te mostrará esta ventana: 
“Quieres que msmtp se instale con su perfil de AppArmor activado” es una capa de seguridad, en mi caso le daré a ***no***, pues puede dar problemas difíciles de depurar en el futuro y en este caso es un servicio muy sencillo.


### 2. Configurar Gmail
>>>Crear archivo de configuración:

```bash
nano ~/.msmtprc
```

Contenido:
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
>❗Entraras en la terminal Telnet, 🔚para salir tienes que presionar la tecla: 

```bash
# Presiona las teclas Ctrl + ]
```

### 5. Probar envío
```bash
echo "Mensaje de prueba" | mail -s "Prueba desde servidor" tu-email@gmail.com
```
>Verifica que llego en tu bandeja de entrada de G-mail

******
----
******

## 🤖 Scripts automáticos

### 🔄 Actualización semanal y correo electrónico automático informando del resultado

#### 1. Mejorar el  script actualizarSistema.sh 

## ¿Qué hay de diferente?

### 🔄 Script mejorado vs versión básica

**Nuevas características:**
- 📧 **Notificaciones por correo** (éxito/error)
- 📁 **Logs diarios** con rotación automática (7 días)
- 🛡️ **Control de errores** avanzado con alertas
- 🧹 **Limpieza automática** de logs antiguos

**Ubicación logs:** `/home/jose/scripts/logs/actualizar_sistema_YYYY-MM-DD.log`

```bash
nano /home/tuUser/scripts/actualizarSistema.sh
```

#### 2. Contenido del script con notificaciones por correo
```bash
#!/bin/bash

# Script para actualizar el servidor automáticamente
# Notifica por correo si hay errores o si se completa correctamente
# Rotación de logs, solo se guardan 7 días de logs

DESTINATARIO="ejemplo@gmail.com"
MSMTP_CONFIG="/home/tuUser/.msmtprc"
LOG_DIR="/home/tuUser/scripts/logs"
FECHA_HOY=$(date +%F)
LOG_FILE="$LOG_DIR/actualizar_sistema_$FECHA_HOY.log"

# Crear directorio de logs
mkdir -p "$LOG_DIR"

# Mantener solo los últimos 7 logs
find "$LOG_DIR" -type f -name 'actualizar_sistema*.log' | sort | head -n -7 | xargs -r rm

# Capturar salida tanto en archivo como en consola
exec > >(tee -a "$LOG_FILE") 2>&1

echo "📦 Actualizando lista de paquetes..."
echo "🕒 Fecha de inicio: $(date)"

if ! apt update; then
    echo "❌ ERROR: Fallo actualización (apt update)."
    echo -e "Subject: ❌ ERROR: Fallo actualización (apt update)\n\nFalló la actualización de paquetes. Ver log adjunto." | msmtp --file="$MSMTP_CONFIG" "$DESTINATARIO"
    exit 1
fi

echo "⬆️ Actualizando paquetes instalados..."
if ! apt upgrade -y; then
    echo "❌ ERROR: Fallo actualización (apt upgrade)."
    echo -e "Subject: ❌ ERROR: Fallo actualización (apt upgrade)\n\nFalló la actualización de paquetes instalados. Ver log adjunto." | msmtp --file="$MSMTP_CONFIG" "$DESTINATARIO"
    exit 1
fi

echo "🧹 Limpiando paquetes innecesarios..."
apt autoremove -y
apt autoclean

echo "---Fin de la actualización del sistema---"

# Notificación de éxito
echo -e "Subject: ✅ Sistema actualizado\n\nEl sistema se actualizó correctamente el $(date)" | msmtp --file="$MSMTP_CONFIG" "$DESTINATARIO"

echo "🔎 Resumen de advertencias (Warnings) del día:"
grep -i "Warning" "$LOG_FILE" | tail -n 5 || echo "✔ Sin advertencias importantes."

exit 0
```

#### 3. Modifica el comando de con y quítale la segunda parte

```bash
crontab -e
0 3 * * 1 /home/tuUser/scripts/actualizarSistema.sh
```

#### 4. 🚀 Validar funcionamiento
```bash
sudo bash /home/tuUser/scripts/actualizarSistema.sh
```
> 🧐Verifica en tu correo si recibiste el e-mail

#### 5. Ver logs

```bash
cat /home/tuUser/scripts/logs/actualizar_sistema_$(date +%F).log
```

> 👀Podrás ver los logs diarios en **(/home/jose/scripts/logs)**

#### 6. 🗑️Limpia los logs viejos *actualizarSistema.log* situados en (/var/log)

 *** Entra en el directorio log viejo:**

```bash
cd /var/log
# Válida si existe actualizarSistema.log:
ls
# Si lo ves,  bórralo
sudo rm -r actualizarSistema.log 
```

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
mkdir -p /home/tuUser/services/portainer
cd /home/tuUser/services/portainer
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
mkdir -p /home/tuUser/services/nginx
cd /home/tuUser/services/nginx
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

*** ⚠️Después de acceder te obligara a modificarlas**


### 5. Configurar dominio con SSL
1. Crear nuevo Proxy Host
2. Domain Names: tu-subdominio.com
3. Forward Hostname/IP: nginxproxymanager  **Definido en container_name que tenemos en el archivo *docker-compose.yaml*.**
4. Forward Port: 81 **Definido en el archivo *docker-compose.yaml*.**
5. En pestaña SSL: Request new SSL certificate


******
----
******

## ☁️ Ejemplo web de prueba

### 1. Crear estructura
```bash
mkdir -p /home/tuUser/services/testweb/www
cd /home/tuUser/services/testweb
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
cd /home/tuUser/services/testweb/www
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

## 💾 Backups automáticos con Duplicati

🔗[Info del contenedor:](https://hub.docker.com/r/linuxserver/duplicati)

### 1. Crear estructura

```bash
mkdir -p /home/tuUser/services/duplicati
cd /home/tuUser/services/duplicati
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

```env
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
>>> guarda el toquen que te muestra

### 7. Acceder

Navegar a: `http://IP-DEL-SERVIDOR:8200`

>>>Nos pedirá el token, pegamos el token guardado en el paso 6.
Al entrar por primera vez nos pedirá una nueva contraseña, la ponemos y la guardamos bien que no se pierda.

## ℹ️Como crear una copia de backup automático con Duplicati

🔗[Link tutorial YouTube:](https://www.youtube.com/watch?v=hoauNQsyer8&t=103s&ab_channel=Unlocoysutecnolog%C3%ADa)



******
----
******



## 🕵️GoAccess analizador de registros del servidor web

>Tutorial completo de configuración paso a paso usando Docker, almacenamiento rotativo y estadísticas web.

🔗[Link tutorial Drive:](https://docs.google.com/document/d/1ufbek7ZnSgSbP3PBvDOkxrzfy_1YnVTzNZ6g5yTwGoM/edit?usp=sharing)


******
----
******

## 🕵️Estructura de como tendria que quedar tus servidor

*** Estrucutra resumida desde */home/tuUser* ***
```text
vps-demo/
├── scripts
│   ├── actualizarSistema.sh
│   ├── limpieza_seguridad_diaria.sh
│   ├── run_goaccess_report.sh
│   └── logs
│          ├── actualizar_sistema_2025-06-05.log
│          └── limpieza_seguridad_diaria.log
└── servers
    ├── duplicati
    │   ├── docker-compose.yaml
    │   ├── .env
    │   ├── backups
    │   └── duplicati-data
    ├── goAccess
    │   ├── docker-compose.yaml
    │   ├──  generate-report.sh
    │   ├──  goaccess.conf
    │   ├──  htpasswd
    │   ├──  nginx.conf
    │   ├── logs
    │   └── reports
    │       ├── info.html
    │       ├── index.html
    │       ├── last_update.txt
    │       ├── data
    │       └── logs
    ├── nginx
    │   ├── docker-compose.yaml
    │   ├── data
    │   │   ├── logs
    │   │   └── nginx
    │   └── letsencrypt
    ├── portainer
    │   ├── docker-compose.yaml
    ├── testweb
           ├─ docker-compose.yam
           └── www
                  └── index.html
```


## Contenido extra ➕➕

## 📊 Monitoreo con crontab

Verificar tareas programadas:
```bash
crontab -l
```

Ver logs de sistema:
```bash
# Ver logs de actualización
cat /home/tuUser/scripts/logs/actualizar_sistema_$(date +%F).log

# Ver logs de limpieza
cat /home/tuUser/scripts/logs/limpieza_seguridad_diaria_$(date +%F).log

```
******
----
******

## 🚨 Comandos útiles

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

### Monitoreo del sistema
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

## 📚 Bibliografía y Recursos 🔗

- **YouTube** 
- **GitHub** 
- **Docker Docs** 
- **Docker Hub Container Image Library** 
- **Solvetic** - Solución a los problemas informáticos 
- **GoAccess** - Visual Web Log Analyzer 
- **EmojiTerra** 🌍 - Emojis Copiar & Pegar 😄

---

> **Nota de seguridad**: Cambia todas las contraseñas y claves de ejemplo por valores seguros antes de usar en producción.