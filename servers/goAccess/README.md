# 🕵️ GoAccess Dockerizado paso a paso 🐋

**Autor:** Jose Rodríguez 👨‍💻

Guía completa  para montar GoAccess Dockerizado. Analizador de registros web con GoAccess, Docker, Nginx y autenticación básica.
El contenedor no se actualiza a tiempo real sino de hora en hora, haciendo que apenas consuma recursos

## 🧰 Si quieres un tutorial más completo lo tienes en: 

🔗[Enlace tutorial Drive:](https://docs.google.com/document/d/1ufbek7ZnSgSbP3PBvDOkxrzfy_1YnVTzNZ6g5yTwGoM/edit?usp=sharing)

## Redes sociales 🌐

**Portfolio**🔗[Enlace portfolio:](https://portfolio.jose-rodriguez-blanco.es)
**LinkedIn**🔗[Enlace LinkedIn:](https://www.linkedin.com/in/joseperfil/)
**GitHub**🔗[Enlace GitHub:](https://github.com/jose-giithub)


******
----
******

## 🤔 ¿Qué vas a conseguir con GoAccess? 📈

Con GoAccess, tendrás una interfaz web para visualizar estadísticas detalladas de tus registros del servidor web, como:

### Estadísticas Principales:
- 👥⏳ Visitantes únicos por día/hora
- 🌍📍 Geolocalización de visitantes
- 💻📱 Navegadores y SO más usados
- 📲🖥️ Dispositivos (móvil/escritorio)
- 🔗🔝 URLs más visitadas
- ⚠️❌ Códigos de error (404, 500, etc.)
- 🤖🕸️ Detección de bots y crawlers
- 🔒💥 Intentos de fuerza bruta
- ✨ Y más...

### Secciones Disponibles:
- 📊 **General Statistics** - Resumen general
- 🚶‍♂️🚶‍♀️ **Unique Visitors** - Visitantes únicos
- 📁 **Requested Files** - Archivos más solicitados
- 🖼️📄 **Static Requests** - Recursos estáticos
- 🚫🔗 **Not Found URLs (404s)** - Páginas no encontradas
- 🏠 **Hosts** - IPs que más visitan
- 🐧🍎 **Operating Systems** - Sistemas operativos
- 🌍 **Browsers** - Navegadores utilizados
- ⏰ **Visit Times** - Horarios de mayor tráfico
- 🌐 **Virtual Hosts** - Diferentes sitios web
- ↩️ **Referrers** - Sitios que envían tráfico
- 🔑 **Keyphrases** - Términos de búsqueda
- 🚦 **HTTP Status Codes** - Códigos de respuesta

🛡️ Además, combinado con herramientas como Fail2Ban (no cubierto en este tutorial pero compatible), puedes reaccionar ante patrones maliciosos detectados en los logs.


******
----
******

## 📋 Requisitos previos

Antes de empezar, asegúrate de tener lo siguiente:

- ✅ Usuario no root con derechos de sudo en el grupo sudo y docker
- ✅ Sistema actualizado
- ✅ fail2ban, ufw, curl, GnuPG, apache2-utils y lsb-release instalados
- ✅ net-tools, nmap y lsof instalados
- ✅ Docker instalado y configurado correctamente (verifica que tu usuario esté en el grupo docker)
- ✅ Nginx Proxy Manager instalado, testeado y funcionando correctamente
- ✅ Un subdominio dedicado para GoAccess (ej. goaccess.tu-dominio.es) apuntando a la IP de tu servidor

Puedes encontrar información detallada sobre cómo realizar estos pasos en tu guía:
🔗[Repositorio GitHub:](https://github.com/jose-giithub/vps-demo/tree/main)

******
----
******

## 🚀 Subir el contenedor GoAccess paso a paso 🐳

Nos situamos en el directorio servers:

```bash
cd /home/tuUser/servers
```

### 1. 📂Crear el directorio goAccess 

```bash
mkdir goAccess
```
---
### 2. 📝 goaccess.conf - Crear archivo de configuración 

Entramos en el nuevo directorio `/home/tuUser/servers/goAccess` y creamos el archivo:

```bash
cd goAccess
nano goaccess.conf
```

Contenido del archivo `goaccess.conf`:

```nginx
server {
    listen 80;
    server_name localhost;

    # Directorio raíz donde están los reportes para la interfaz web
    root /usr/share/nginx/html;
    index welcome.html index.html;
    #index info.html index.html;

    # Configuración de seguridad
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;

    # Logs de acceso y errores
    access_log /var/log/nginx/goaccess_access.log;
    error_log /var/log/nginx/goaccess_error.log;

    # Página principal - requiere autenticación
    location / {
        auth_basic "GoAccess - Área Restringida";
        auth_basic_user_file /etc/nginx/.htpasswd;

        try_files $uri $uri/ =404;

        # Configuración de caché para archivos estáticos
        location ~* \.(css|js|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
            expires 1h;
            add_header Cache-Control "public, immutable";
        }
    }

    # Archivo de última actualización - sin autenticación para APIs
    location /last_update.txt {
        auth_basic off;
        add_header Content-Type text/plain;
        add_header Access-Control-Allow-Origin "*";
    }

    # Endpoint de salud - sin autenticación
    location /health {
        auth_basic off;
        access_log off;
        return 200 "OK - GoAccess Web Server";
        add_header Content-Type text/plain;
    }

    # Denegar acceso a archivos sensibles
    location ~ /\. {
        deny all;
        access_log off;
        log_not_found off;
    }

    # Denegar acceso al directorio de datos
    location /data/ {
        deny all;
        access_log off;
        log_not_found off;
    }

    # Configuración para reportes HTML grandes
    client_max_body_size 10M;

    # Configuración de compresión
    gzip on;
    gzip_vary on;
    gzip_min_length 1000;
    gzip_types
        text/plain
        text/css
        text/js
        text/xml
        text/javascript
        application/javascript
        application/xml+rss
        application/json;
}
```

💾 Presiona `Ctrl + X` para salir y guardar. 

---

### 3. 📝 generate-report.sh - Creamos el script 

Creamos el archivo en el directorio goAccess (`/home/tuUser/servers/goAccess`):

```bash
nano generate-report.sh
```

Contenido del archivo `generate-report.sh`:

```bash
#!/bin/bash
# Script para generar reportes de GoAccess
# Optimizado para ser ejecutado por cron
echo "📦 Actualizando html lo GoAccess"
LOG_DIR="/opt/log"
REPORT_DIR="/srv/report"
CONFIG_FILE="/etc/goaccess/goaccess.conf"

# Crear directorio de reportes si no existe
mkdir -p "$REPORT_DIR/data"

# Función para generar reporte
generate_report() {
    echo "$(date): Generando reporte de GoAccess..."
    # Encontrar todos los archivos de log de proxy-host
    # Asegúrate de que esta ruta sea correcta dentro del contenedor
    LOG_FILES=$(find "$LOG_DIR" -name "proxy-host-*_access.log" -type f)
    if [ -z "$LOG_FILES" ]; then
        echo "$(date): No se encontraron archivos de log en $LOG_DIR"
        # Salir con un código de error para que cron lo detecte si no hay logs
        exit 1
    fi
    # Ejecutar GoAccess con los logs encontrados y la configuración
    # Ya no es necesario pasar todas las opciones aquí, ya que están en goaccess.conf
    goaccess $LOG_FILES --config-file="$CONFIG_FILE"
    if [ $? -eq 0 ]; then
        echo "$(date): Reporte generado exitosamente en $REPORT_DIR/index.html"
        # Actualizar timestamp del último reporte
        echo "$(date)" > "$REPORT_DIR/last_update.txt"
    else
        echo "$(date): Error al generar el reporte de GoAccess. Revisar logs."
        exit 1 # Salir con un código de error
    fi
}

# Ejecutar la función principal
generate_report
echo "✅ Html actualizado correctamente"
```

💾 Presiona `Ctrl + X` para salir y guardar. 

---

### 4. 🔐Dar permisos al script 

```bash
chmod +x generate-report.sh
```
---

### 5. 📝run_goaccess_report.sh - Crea el archivo ejecutable 

Este script será el que cron ejecute cada hora para actualizar el HTML con la información de los logs.

#### ¿Qué hace este archivo?

- **Verificar directorios**: Accede al directorio de GoAccess y valida la ruta. 📂✅
- **Ejecutar contenedor temporal**: Lanza un contenedor Docker de GoAccess con `--rm` (se elimina automáticamente). 🐳🗑️
- **Procesar logs**: Analiza los logs de Nginx Proxy Manager usando la configuración personalizada. 🔍📊
- **Generar reportes HTML**: Ejecuta el script `generate-report.sh` dentro del contenedor para crear estadísticas actualizadas. 📈✨
- **Guardar resultados**: Los reportes se almacenan en el directorio compartido `/reports`. 💾
- **Registrar actividad**: Guarda logs de la operación en `/home/tuUser/goaccess_cron.log`. 📝
- **Limpieza automática**: El contenedor se elimina automáticamente tras cada ejecución (flag `--rm`). 🧹

**Ventaja clave**: Solo consume recursos del servidor durante la generación de reportes (unos minutos cada hora), manteniendo el servidor web siempre disponible pero optimizando el uso de memoria y CPU. 🔋⚡

En tu host, fuera de la carpeta goAccess, en el directorio scripts situado en `/home/tuUser/scripts/`, crea el archivo:

```bash
nano /home/tuUser/scripts/run_goaccess_report.sh
```

Contenido del archivo `run_goaccess_report.sh`:

```bash
#!/bin/bash
docker run --rm \
 -e LANG=es_ES.UTF-8 \
 --name goaccess_cron_runner \
 --network proxiable \
 -v "/home/tuUser/servers/nginx/data/logs:/opt/log:ro" \
 -v "/home/tuUser/servers/goAccess/goaccess.conf:/etc/goaccess/goaccess.conf:ro" \
 -v "/home/tuUser/servers/goAccess/reports:/srv/report" \
 -v "/home/tuUser/servers/goAccess/generate-report.sh:/usr/local/bin/generate-report.sh:ro" \
 --entrypoint sh \
 allinurl/goaccess:latest \
 -c "/usr/local/bin/generate-report.sh" # Comando principal del contenedor para ejecutar el script

# Actualizar el archivo last_update.txt con la fecha y hora de la última generación del reporte
date +"Última actualización del reporte GoAccess: %Y-%m-%d %H:%M:%S %Z" > \
"/home/tuUser/servers/goAccess/reports/last_update.txt"

EXIT_CODE=$?
if [ $EXIT_CODE -eq 0 ]; then
 echo "Comando docker run para GoAccess finalizado. Salida del script interno:" >> "/home/tuUser/scripts/logs/goaccess_cron.log"
else
 echo "ERROR: Fallo en el comando docker run para GoAccess. Código de salida: $EXIT_CODE" >> "/home/tuUser/scripts/logs/goaccess_cron.log"
fi
echo "--- Fin ---" >> "/home/tuUser/scripts/logs/goaccess_cron.log"
```

💾 Presiona `Ctrl + X` para salir y guardar. 

**⚠️Recuerda:⚠️**
- Asegúrate de que los logs de Nginx Proxy Manager estén realmente en `/home/tuUser/servers/nginx/data/logs`. Puedes verificarlo con:

```bash
cd /home/tuUser/servers/nginx/data/logs
ls -l
```

- 🕵️‍♂️ Que los nombres de los logs tienen el mismo nombre que pones en el .yml, .sh y .conf. 
- 🔑 Verificar Permisos de los archivos .log que tengan permisos de lectura (`-rw-r--r--`). 

---

### 6. 🚀Convertir el archivo run_goaccess_report.sh en ejecutable

```bash
chmod +x /home/tuUser/scripts/run_goaccess_report.sh
```
---

### 7. 🤖Automatizar la ejecución del archivo cada hora 

```bash
crontab -e
```

Se abrirá un archivo, tienes que añadir el código:

```bash
0 * * * * /home/tuUser/scripts/run_goaccess_report.sh
```

Esto lo ejecutará automáticamente cada hora.

**🚀Validar que el ejecutable de crontab funciona como se espera:**

Simula que eres el crontab y lanza la ejecución:

```bash
sudo bash /home/tuUser/scripts/run_goaccess_report.sh
```

🕵️‍♂️ Luego puedes revisar el log con:

```bash
cat /home/tuUser/scripts/logs/goaccess_cron.log
```
---

### 8.📂 Crear el directorio "reports" 

Dentro del directorio goAccess con ruta `/home/tuUser/servers/goAccess`:

```bash
mkdir reports
```
---

### 9. 📂Crear el directorio "data" 

Dentro del directorio reports con ruta `/home/tuUser/servers/goAccess/reports`, entramos y creamos el directorio data:

```bash
cd /home/tuUser/servers/goAccess/reports
mkdir data
```

**⚠️Recuerda:⚠️**👤✍️ Todos los directorios tienen que tener como propietario tu usuario (user no root) y tener permisos de escritura. 

👁️ Ejemplo de directorio con permisos apropiados: `drwxrwxr-x 2 tuUser tuUser 4096 May 31 20:39`

---

### 10.📝 info.html - Crea el archivo .html

Entra en el directorio recién creado reports (`/home/tuUser/servers/goAccess/reports`) y crea el archivo info.html:

```bash
nano info.html
```

Contenido del archivo `info.html`:

```html
<!DOCTYPE html>
<html lang="es">
<head>
 <meta charset="UTF-8">
 <meta name="viewport" content="width=device-width, initial-scale=1.0">
 <title>GoAccess - Información</title>
 <style>
 body { font-family: Arial, sans-serif; margin: 20px; background: #f5f5f5; }
 .container { max-width: 800px; margin: 0 auto; background: white; padding: 20px; border-radius: 8px;
box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
 .header { text-align: center; color: #333; border-bottom: 2px solid #4CAF50; padding-bottom: 10px; }
 .info { margin: 20px 0; }
 .btn { display: inline-block; padding: 10px 20px; background: #4CAF50; color: white; text-decoration: none;
border-radius: 4px; margin: 5px; }
 .btn:hover { background: #45a049; }
 .status { padding: 10px; background: #e8f5e8; border-left: 4px solid #4CAF50; margin: 10px 0; }
 </style>
</head>
<body>
 <div class="container">
 <h1 class="header">🔍 GoAccess - Panel de Estadísticas Web</h1>

 <div class="status">
 <strong>Estado:</strong> Servicio activo y funcionando
 </div>

 <div class="info">
 <h3>📊 Información del Sistema</h3>
 <ul>
 <li><strong>Servidor:</strong> tu_dominio.es</li>
 <li><strong>Actualización:</strong> Cada hora automáticamente</li>
 <li><strong>Logs analizados:</strong> Nginx Proxy Manager</li>
 <li><strong>Sitios monitoreados:</strong> Todos los proxy-hosts configurados</li>
 </ul>
 </div>

 <div class="info">
 <h3>🔗 Enlaces Rápidos</h3>
 <a href="/index.html" class="btn">📈 Ver Estadísticas Completas</a>
 <a href="/last_update.txt" class="btn">🕐 Última Actualización</a>
 </div>

 <div class="info">
 <h3>ℹ️ Notas</h3>
 <p>Este panel muestra estadísticas detalladas de tráfico web incluyendo:</p>
 <ul>
 <li>Visitantes únicos y páginas vistas</li>
 <li>Países y ciudades de origen</li>
 <li>Navegadores y sistemas operativos</li>
 <li>URLs más visitadas</li>
 <li>Códigos de respuesta HTTP</li>
 <li>Detección de intentos de fuerza bruta</li>
 </ul>
 </div>
 </div>
</body>
</html>
```

💾 Presiona `Ctrl + X` para salir y guardar. 

---

### 11. 📝 nginx.conf - Creamos el archivo de configuración 

Esta configuración de Nginx es para el servidor web con autenticación. El archivo lo creamos en el directorio goAccess (`/home/tuUser/servers/goAccess`):

```bash
nano nginx.conf
```

Contenido del archivo `nginx.conf`:

```nginx
server {
    listen 80;
    server_name localhost;

    # Directorio raíz donde están los reportes
    root /usr/share/nginx/html;
    index info.html index.html;

    # Configuración de seguridad
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;

    # Logs de acceso y errores
    access_log /var/log/nginx/goaccess_access.log;
    error_log /var/log/nginx/goaccess_error.log;

    # Página principal - requiere autenticación
    location / {
        auth_basic "GoAccess - Área Restringida";
        auth_basic_user_file /etc/nginx/.htpasswd;

        try_files $uri $uri/ =404;

        # Configuración de caché para archivos estáticos
        location ~* \.(css|js|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
            expires 1h;
            add_header Cache-Control "public, immutable";
        }
    }

    # Archivo de última actualización - sin autenticación para APIs
    location /last_update.txt {
        auth_basic off;
        add_header Content-Type text/plain;
        add_header Access-Control-Allow-Origin "*";
    }

    # Endpoint de salud - sin autenticación
    location /health {
        auth_basic off;
        access_log off;
        return 200 "OK - GoAccess Web Server";
        add_header Content-Type text/plain;
    }

    # Denegar acceso a archivos sensibles
    location ~ /\. {
        deny all;
        access_log off;
        log_not_found off;
    }

    # Denegar acceso al directorio de datos
    location /data/ {
        deny all;
        access_log off;
        log_not_found off;
    }

    # Configuración para reportes HTML grandes
    client_max_body_size 10M;

    # Configuración de compresión
    gzip on;
    gzip_vary on;
    gzip_min_length 1000;
    gzip_types
        text/plain
        text/css
        text/js
        text/xml
        text/javascript
        application/javascript
        application/xml+rss
        application/json;
}
```

💾 Presiona `Ctrl + X` para salir y guardar. 

---

### 12.🔑 htpasswd - Crear archivo para Usuario y Contraseña 

El archivo lo creamos en el directorio goAccess (`/home/tuUser/servers/goAccess`). Este archivo nos dará un usuario y contraseña para acceder a la interfaz web de GoAccess.

```bash
htpasswd -c htpasswd tuUser
```

🔒 Después de ejecutar este comando se pedirá que añadas una contraseña, guárdala bien. 

Ejemplo:
```
user@vmi259:~/servers/goAccess$ htpasswd -c htpasswd nomUser
New password:
Re-type new password:
Adding password for user nomUser
```
---

### 13.📝 docker-compose.yaml

Entramos en el directorio goAccess (`/home/tuUser/servers/goAccess`) y creamos el archivo:

```bash
nano docker-compose.yaml
```

Contenido del archivo `docker-compose.yaml`:

```yaml
services:
  goaccess:
    image: allinurl/goaccess:latest
    container_name: goaccess
    restart: "no" # No reiniciar automáticamente, el script se encarga de su ejecución

    # Variables de entorno para configuración
    environment:
      - TZ=Europe/Madrid
      - GOACCESS_CONFIG_FILE=/etc/goaccess/goaccess.conf

    volumes:
      # Logs de Nginx Proxy Manager (solo lectura)
      - /home/tuUser/servers/nginx/data/logs:/opt/log:ro # verificar que se encuentran ahí: ls -lh /home/tuUser/servers/nginx/data/logs
      # Configuración personalizada de en archivo se encuentra en /home/tuUser/servers/goAccess
      - ./goaccess.conf:/etc/goaccess/goaccess.conf:ro
      # Directorio donde se generarán los reportes HTML
      - ./reports:/srv/report
      # Script personalizado para generar reportes, archivo se encuentra en /home/tuUser/servers/goAccess
      - ./generate-report.sh:/usr/local/bin/generate-report.sh:ro

    networks:
      - proxiable

  # CONTENEDOR 2: Servidor web para mostrar los reportes
  goaccessWeb:
    image: nginx:alpine
    container_name: goaccessWeb
    restart: unless-stopped # Reiniciar automáticamente si no se detiene explícitamente

    volumes:
      # Los reportes generados por GoAccess directorio situado en /home/tuUser/servers/goAccess/reports
      - ./reports:/usr/share/nginx/html:ro
      # Configuración de Nginx con autenticación básica situado en /home/tuUser/servers/goAccess
      - ./nginx.conf:/etc/nginx/conf.d/default.conf:ro
      # Archivo de usuarios para autenticación situado en /home/tuUser/servers/goAccess
      - ./htpasswd:/etc/nginx/.htpasswd:ro
    networks:
      - proxiable
    expose:
      - "80"
    depends_on:
      - goaccess # Asegura que el servicio 'goaccess' se inicie antes

networks:
  proxiable:
    external: true # Usar la red 'proxiable' ya existente (creada por Nginx Proxy Manager)
```

💾 Presiona `Ctrl + X` para salir y guardar. 

**🕵️Validaciones del archivo .yml:**

Logs de Nginx Proxy Manager: Asegúrate de que estén en el directorio indicado (`/home/tuUser/servers/nginx/data/logs`). Puedes verificarlo con:

```bash
ls -lh /home/tuUser/servers/nginx/data/logs
```
---

### 14. 🚀Levanta el contenedor goaccessWeb 

¡Solo levantamos el servidor web y este se encargará de levantar el servicio goaccess (por la dependencia `depends_on`)!

Sitúate en el directorio goAccess. Ruta: (`/home/tuUser/servers/goAccess`)

```bash
docker compose up -d goaccessWeb
```
---

### 15.🌐🔒 Añadir dominio y certificado HTTPS a nuestro contenedor 

1. **Acceder a Nginx Proxy Manager**: 
`http://IP.DE.TU.SERVIDOR:81` o `https://nginx.dominio.es:81`

2. **Crear nuevo Proxy Host**:
   - **Domain Names**: goaccess.tu-dominio.es (el subdominio para la interface web de GoAccess)
   - **Forward Hostname/IP**: `goaccessWeb` (nombre del contenedor que tienes en el container_name en el .yml)
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

🌐Finalmente, entra en tu dominio `https://goaccess.tu-dominio.es` y tendrías que ver el contenido del archivo info.html (te pedirá usuario y contraseña que configuraste en htpasswd).

## 🔧 Comandos Útiles 💡

**🗑️Detener y eliminar el contenedor y servicio goaccess:**

```bash
docker compose down -v goaccess
docker compose down -v goaccessWeb
```

**➡️Entrar en el contenedor goaccess para depuración:**

```bash
docker run --rm -it \
 -e LANG=es_ES.UTF-8 \
 --name goaccess_debugger \
 --network proxiable \
 -v "/home/tuUser/servers/nginx/data/logs:/opt/log:ro" \
 -v "/home/tuUser/servers/goAccess/goaccess.conf:/etc/goaccess/goaccess.conf:ro" \
 -v "/home/tuUser/servers/goAccess/reports:/srv/report" \
 --entrypoint sh \
 allinurl/goaccess:latest
```

**🔎 Ver el contenido de algún log:**

```bash
head -n 1 /home/tuUser/servers/nginx/data/logs/nom_log.log
```

**🕵️‍♂️Validar formato de log:**

```bash
docker run --rm \
 -v /home/tuUser/servers/nginx/data/logs:/logs:ro \
 allinurl/goaccess \
 /logs/proxy-host-16_access.log \
 --log-format='[%d:%t %z] %^ %^ %s %^ %m %^ %v "%U" [Client %h] [Length %b] [Gzip %^] [Sent-to %^] "%u" "%R"' \
 --date-format='%d/%b/%Y' \
 --time-format='%H:%M:%S' \
 --no-progress
```

**🧑‍🏫 Explicación:**
- `/logs/proxy-host-16_access.log`: Puede ser cualquier tipo de log, solo modifica el nombre del que gustes. 📝
- `--log-format='...'`, `--date-format='...'`, `--time-format='...'`: Tienen que coincidir con el que tienes en goaccess.conf. ⚙️

**Generar reporte manual de un archivo específico:**

```bash
docker run --rm \
 -v /home/tuUser/servers/nginx/data/logs:/logs:ro \
 -v /home/tuUser/servers/goAccess/reports:/report \
 allinurl/goaccess \
 /logs/proxy-host-15_access.log \
 --log-format='[%d:%t %z] %^ %^ %s %^ %m %^ %v "%U" [Client %h] [Length %b] [Gzip %^] [Sent-to %^] "%u" "%R"' \
 --date-format='%d/%b/%Y' \
 --time-format='%H:%M:%S' \
 -o /report/index.html
```

**🚀Ejecutar el script de cron manualmente:**

```bash
sudo bash /home/tuUser/scripts/run_goaccess_report.sh
```

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
