># 💻Laravel Dockerizado paso a paso🐋

Montar un web dinámica usando el framework de Laravel + certificado HTTPS con Nginx Proxy Manager + base de datos MariaDB + gestión de la base de datos desde una interface gráfica phpMyAdmin y todo Dockerizado

**Autor**: Jose Rodríguez  

## Redes sociales 🌐

**Portfolio**🔗[Enlace portfolio:](https://portfolio.jose-rodriguez-blanco.es)
**LinkedIn**🔗[Enlace LinkedIn:](https://www.linkedin.com/in/joseperfil/)
**GitHub**🔗[Enlace GitHub:](https://github.com/jose-giithub)

***
---
***


>## 📋 Índice

- [🤔 ¿Qué encontraremos en este tutorial?](#tutorial)
- [🚧 Requisitos previos](#requisitos)
- [⚠️ Tener en cuenta](#tener-en-cuenta)
- [📂 Creamos la estructura para nuestra base de datos](#estructura)
- [📝 Creamos el documento docker-compose.yml](#compose)
- [📝 Creamos el documento Dockerfile](#dockerfile)
- [📝 Creamos el documento laravel.conf](#nginx-conf)
- [💻 Enviar y descomprimir nuestro proyecto Laravel](#descomprimir)
- [📝 Editamos el documento .env](#env)
- [🚀 Levantar el contenedor](#levantar)
- [📝 Creamos el documento fix-permissions.sh](#fix-permissions)
- [🔑 Dar permisos al usuario no root de MariaDB](#permisos-phpmyadmin)
- [📝 Crea un archivo .gitignore](#gitignore)
- [🌳 Estructura del Proyecto](#estructura-proyecto)
- [🔎 Test de validación](#validacion)
- [🛠️ Crear las key, seeders migration etc.](#artisan)
- [🌐 Configurar Nginx Proxy Manager](#nginx-proxy)
- [💪 Forzar HTTPS](#https)
- [😣 Solución: Las imágenes no se cargan](#imagenes)

***
---
***

>## <a name="tutorial"> 🤔 ¿Qué encontraremos en este tutorial? </a>      

Vamos a levantar una imagen de Laravel en nuestro servidor con compose y conectado a una base de datos ya establecida anteriormente.

Aunque este proyecto sea un ejemplo, también tendrá un paquete completo de herramientas instaladas para el desarrollo y testeo, tales como por ejemplo nano, npm o nodejs.

---
## 🧰 Si quieres uno tutorial más completo y detallado lo tienes en: 
🔗[💻Laravel Dockerizado paso a paso🐋, tutorial Drive:](https://docs.google.com/document/d/12wyY_QgqCda8Ls375-2NF69_J9Q8g2BE_eGDx2_KYoE/edit?usp=sharing)

***
---
***

>## <a name="requisitos">🚧 Requisitos previos</a>


1. ✅ Tener un servidor basado en Linux. En este tutorial se usa un Ubuntu 24.04.2 LTS (Noble Numbat).
2. ✅ Tener un dominio y subdominio
3. ✅ Conocer la IP pública de nuestro servidor.
4. ✅ Tener un user no root con derechos de *sudo* en el *grupo sudo y docker*.
5. ✅ Tener instalada en el servidor herramientas de descompresión de archivos como *7-Zip*
6. ✅ Algún sistema de transferencia de archivos entre nuestro PC y el servidor (No obligatorio pero ayuda)
7. ✅ Tener instalado *docker*.
8. ✅ Tener instalada la imagen de Nginx proxy manager testeado y sabiendo que funciona bien.

  >  Puedes tener toda la información de como realizar estos pasos en:

- Documento Drive

🔗[Configurar VPS desde 0 paso a paso, tutorial Drive:](https://docs.google.com/document/d/1RMoX8kUR3lRntgdGNtjpnFPkNULrNoSefXUzDBEabOE/edit?usp=sharing)

- Tutorial en GitHub

🔗[Configurar VPS desde 0 paso a paso, tutorial GitHub:](https://github.com/jose-giithub/vps-demo/tree/main)

9. ✅ Tener instaladas las imágenes de MariaDB y phpMyAdmin

  > Puedes tener toda la información de como realizar estos pasos en:

   - Documento Drive

🔗[Base de datos MariaDB e interface web PhpMyAdmin Dockerizado, tutorial Drive:](https://docs.google.com/document/d/1iteWeHyYgD4lyjB1zA_IN_j3bb_SpFukxwEdetI4Eo8/edit?usp=sharing)

- Tutorial en GitHub

🔗[Base de datos MariaDB e interface web PhpMyAdmin Dockerizado, tutorial GitHub:](https://github.com/jose-giithub/vps-demo/tree/main/servers/database)

***
---
***

>## <a name="tener-en-cuenta">⚠️️ Tener en cuenta</a> 

⚠️️ **Todo lo que haremos será con el usuario no root** ⚠️️️

```bash 
su tuUser
```
---

**⚠️ Modifica *tuUser* por tu usuario del servidor.**

***
---
***

>## <a name="estructura">📂 Creamos la estructura para nuestro proyecto</a>


📂 Entramos en el directorio *servers* con ruta */home/tuUser/servers* y creamos el nuevo directorio laravel_example.

```bash
cd home/tuUser/servers
mkdir laravel_example
```

ℹ️ Ruta completa */home/tuUser/servers/laravel_example*

📂 Entramos en el nuevo directorio *laravel_example* y creamos los directorios *nginx*, *www*

```bash
cd /home/tuUser/servers/laravel_example
mkdir nginx www
```

***
---
***

>## <a name="compose">📝 Creamos el documento docker-compose.yml</a>


✅ Entramos en el directorio "laravel_example" y creamos el 📝archivo docker-compose.yml, que contiene la configuración principal del proyecto.

```bash
cd /home/tuUser/servers/laravel_example
nano docker-compose.yml
```

**Contenido:**

```yml
services:
  #📦CONTENEDOR 1: 🏡 PHP en el que se ejecutará Laravel
  laravel_example_php:
    container_name: laravel_example_php
    build:
      args:
        #Usuario que corre los contenedores. Tienen que coincidir el usuario y el ID del host y el contenedor
        user: ${USER_NAME} # Nombre usuario servidor
        uid: ${USER_UID} # ID del usuario servidor
      # Ruta donde encontrara el archivo Dockerfile
      context: ./
      dockerfile: Dockerfile # Hace referencia al archivo Dockerfile
    restart: unless-stopped
    working_dir: /var/www/
    volumes: # volúmenes que creara al subir el contenedor
      - ./www:/var/www
    env_file: # Archivo donde guardar la info importante
      - ./.env # Especifica la ruta a tu nuevo archivo .env
    # Redes por las que se comunican los contenedores, comando para validar las redes: docker network ls
    networks:
      - proxiable

  #📦CONTENEDOR 2: 🌐Servidor web inverso.
  # Encargado de servir la aplicación Laravel (que corre en el contenedor *laravel_example_php*
  laravel_example_nginx:
    image: nginx:latest
    container_name: laravel_example_nginx
    restart: unless-stopped
    # Expongo los puertos para que Nginx proxy manager se ocupe del trafico
    expose:
      - "80"
      - "443"
      - "5173"
    volumes:
      - ./www:/var/www
      - ./nginx:/etc/nginx/conf.d/
      # 🔎 Mapeamos el directorio de logs para poder consultar errores y accesos de Laravel desde fuera del contenedor (opcional).
      - /home/tuUser/servers/laravel_example/nginx/data/logs:/var/log/nginx # ⚠️Ruta completa donde crear los logs laravel_example_error.log y laravel_example_access.log.
    networks:
      - proxiable

# Redes
networks:
  proxiable:
    external: true

# ⚠️*NO MONTAMOS* ⚠️porque ya tengo una base de datos creada:
# 📦❌CONTENEDOR *MariaDB* para la configura la base de datos MariaDB
# 📦❌CONTENEDOR *phpMyAdmin* Herramienta gráfica para gestionar ls bases de datos.
```

ℹ️ control + x para salir y guardar

### 📝 Observaciones del documento

A partir de Laravel 11 puedes usar una base de datos externa o usar una base de datos interna SQLite, en mi caso voy a conectarme a una base de datos MariaDB que ya existe en mi servidor. Si no tienes base de datos te recomiendo este tutorial donde explico como montar una en tu servidor, de esta forma podrás tener muchas webs y 1 sola base de datos, de esta forma ahorras recursos.

Puedes tener toda la información de como realizar estos pasos en:

 - Documento Drive

🔗[Base de datos MariaDB e interface web PhpMyAdmin Dockerizado, tutorial Drive:](https://docs.google.com/document/d/1iteWeHyYgD4lyjB1zA_IN_j3bb_SpFukxwEdetI4Eo8/edit?usp=sharing)

- Tutorial en GitHub

🔗[Base de datos MariaDB e interface web PhpMyAdmin Dockerizado, tutorial GitHub:](https://github.com/jose-giithub/vps-demo/tree/main/servers/database)

✅📝 En el mismo directorio *laravel_example* creamos el archivo *.env*

Crearemos un archivo oculto y protegido para que solo se pueda leer y modificar con "sudo" y desde el archivo .yml leeremos ese archivo

```bash
cd /home/tuUser/servers/laravel_example
nano .env
```

**Contenido:**

```bash
# Info oculta para el archivo docker-compose.yml
# Comando para averiguar los user y sus uid: id
# Hace referencia al *user* del docker-compose.yml
USER_NAME=tuUser
# Hace referencia a *uid* del docker-compose.yml
USER_UID=1001
```

ℹ️ control + x para salir y guardar

✅ 🔐 Modificamos los permisos del archivo .env

```bash
chmod 600 .env
```

🕵 Al validar tendría que salir algo del estilo

```bash
ls -la
-rw-------  1 tuUser tuUser          171 Jun 17 00:58 .env
```

⚠️ **No subas nunca este archivo .env a un repositorio público (GitHub, GitLab, etc.). Contiene datos sensibles como credenciales de acceso a la base de datos y variables de entorno.**

***
---
***

>## <a name="dockerfile">📝 Creamos el documento *Dockerfile*</a>


📂 Entramos en el directorio *"*laravel_example*"* y creamos el *Dockerfile*

```bash
cd /home/tuUser/servers/laravel_example
nano Dockerfile
```

**Contenido:**

```dockerfile
FROM php:8.3.8-fpm

# Arguments defined in docker-compose.yml
ARG user
ARG uid

# 🧰 Install system dependencies dentro del contenedor de forma global
RUN apt-get update && apt-get install -y \
    git \
    curl \
    #nano para ver documentos y archivos
    nano \
    #ping para hacer ping entre contenedores
    iputils-ping \
    #cliente mysql
    default-mysql-client \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    npm

# 🧰 Install system dependencies dentro del contenedor de forma global a parte para asegurar que usas una versión específica y moderna.
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs

# Install npm vite
# CÓDIGO DE PRUEBAS, lo comento para que no se instale de forma global
# RUN npm install --save-dev vite

# 🧹 Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# 🛠Install PHP extensions
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

# Get latest Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Create system user to run Composer and Artisan Commands
RUN useradd -G www-data -u $uid -d /home/$user $user
RUN mkdir -p /home/$user/.composer && \
    chown -R $user:$user /home/$user

# Set working directory
WORKDIR /var/www
```

### 📝 Observaciones del documento


Se instalan herramientas de desarrollo avanzado como *nodejs, npm* y herramientas para depuración como *nano, ping,* etc. Para un Laravel básico no hacen falta, pero con este kit podrás tener una web cojonuda.

***
---
***

>## <a name="nginx-conf">📝 Creamos el documento *laravel.conf*</a>


📂 Entramos en el directorio *laravel_example/nginx* y creamos el archivo *laravel.conf*

```bash
cd /home/tuUser/servers/laravel_example/nginx
nano laravel.conf
```

**Contenido:**

```nginx
server {
    listen 80; # Escucha en el puerto 80
    index index.php index.html; # Prioridad de archivos al abrir una carpeta. Busca index.php. Si no existe, busca index.html.
    
    #ℹ️ Archivos logs para revisar errores. Se guardan en: /home/tuUser/servers/laravel_example/nginx/data/logs
    error_log /var/log/nginx/laravel_example_error.log; # si Nginx  tiene errores, los guarda aquí.
    access_log /var/log/nginx/laravel_example_access.log; # cada vez que alguien accede, guarda un registro aquí.
    
    root /var/www/public; # Laravel empieza en la carpeta public, no en la raíz /var/www Esto protege tus archivos internos de Laravel (env, routes, etc).
    
    location ~ \.php$ { # llega un archivo .php (por ejemplo index.php).
        try_files $uri =404; # Si existe el archivo ($uri), lo usa, si no error 404
        fastcgi_split_path_info ^(.+\.php)(/.+)$; #Divide el nombre del archivo PHP y los parámetros del URL.
        fastcgi_pass laravel_example_php:9000; # ℹ️ Enviar las peticiones PHP al contenedor de *laravel_example_php* (haciendo referencia al archivo docker-compose.yml) por el puerto 9000
        fastcgi_index index.php; # Si falla ejecutar, por defecto usa index.php.
        include fastcgi_params; # Cargar parámetros estándar de NGINX. variables necesarias para que PHP-FPM funcione bien.
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name; # Decirle exactamente a PHP cuál archivo tiene que ejecutar.
        fastcgi_param PATH_INFO $fastcgi_path_info; #Enviar también información sobre el "path" adicional (si hay).
    }
    
    location / { #Gestionar las rutas
        try_files $uri $uri/ /index.php?$query_string; # busca si existe la carpeta o archivo. Si no existe, redirige automáticamente a index.php con los parámetros correctos.
        gzip_static on; # Servir archivos comprimidos .gz si existen
    }
}
```

ℹ️ control + x para salir y guardar

 📁 **Nota importante sobre esta línea del archivo `laravel.conf`:**

 ```bash
 root /var/www/public;
```

Esta línea indica a Nginx que la carpeta pública de tu proyecto Laravel está en `/public`, no en la raíz del proyecto.

 Laravel **NO debe exponer toda la carpeta del proyecto**, ya que contiene archivos sensibles (`.env`, rutas, controladores, etc.).

👉 Si esta línea apunta mal (por ejemplo a `/var/www`), Laravel mostrará errores **403 Forbidden** o dejará expuestos archivos críticos.  

 Por eso, **siempre** debe apuntar a la carpeta `public` donde está el archivo `index.php` que sirve como punto de entrada de la app.


***
---
***

>## <a name="descomprimir">💻 Enviar y descomprimir nuestro proyecto Laravel</a>


1. **Comprimimos todos los archivos:**
   De nuestro proyecto local de Laravel lo comprimimos usando la herramienta 7z

2. **Importante de nuestro PC a nuestro servidor**
   Alojamos nuestro Laravel comprimido en el directorio *laravel_example* y  descomprimimos los archivos y directorios de Laravel dentro del directorio *www*.

⚠️ **Los archivos y directorios de Laravel tienen que estar alojados dentro del directorio *www*, ⛔ nunca puede haber otro directorio dentro de *www* como por ejemplo *miLaravel* y ahí dentro los archivos y directorios de Laravel.**

ℹ️ Si no tienes instalado 7 zip:

```bash
sudo apt update
sudo apt install p7zip-full
```

Comando para descomprimir tu archivo en el directorio www:

```bash

7z x laravelLocal.7z -o./www

```
**⚠️Asegúrate de tenerlo de este modo**

```text

📂www
      ├──📄 .env 
      └──📄📂📄📂📄📂📄📂 Toda la estructura de Laravel
```

***
---
***

>## <a name="env">📝 Editamos el documento *.env* de Laravel</a>


📂 Entramos en el directorio *laravel_example/www* y editamos el archivo *.env*

⚠️ ¡Atención! Este es el segundo archivo .env que vamos a editar. Corresponde a la configuración interna de Laravel y se encuentra en la carpeta www/. No debe confundirse con el archivo .env que creamos en la raíz para docker-compose.

ℹ️ Este archivo es el que contiene todas las variables para que Laravel trabaje correctamente en producción y se conecte a la base de datos.

```bash
cd /home/tuUser/servers/laravel_example/www
nano .env
```

**Contenido:**

```bash

# **************LOCAL***************
# APP_NAME=Laravel-ejemplo
# # APP_ENV=local
# APP_KEY= # Puedes generarla con php artisan key:generate
# APP_DEBUG=true
# #APP_TIMEZONE=UTC
# APP_TIMEZONE=Europe/Madrid
# APP_URL=http://localhost
# *****************************************

# **************PRODUCCIÓN***************
APP_NAME=Laravel-ejemplo
APP_ENV=production
APP_KEY= # Puedes generarla con php artisan key:generate
APP_DEBUG=false
APP_URL=tu.dominio.es
APP_TIMEZONE=Europe/Madrid
# *****************************************

# Ponemos las configuraciones en Español
APP_LOCALE=es
APP_FALLBACK_LOCALE=es
APP_FAKER_LOCALE=es
APP_MAINTENANCE_DRIVER=file
# APP_MAINTENANCE_STORE=database

PHP_CLI_SERVER_WORKERS=4

BCRYPT_ROUNDS=12

LOG_CHANNEL=stack
LOG_STACK=single
LOG_DEPRECATIONS_CHANNEL=null

# **************LOCAL***************
# LOG_LEVEL=debug
# **************PRODUCCIÓN***************
LOG_LEVEL=error

# **************CONEXIÓN CON LA DATABASE LOCAL***********************
# DB_CONNECTION=mysql
# #DB_CONNECTION=sqlite
# DB_HOST=127.0.0.1
# DB_PORT=3306
# DB_DATABASE=bd_laravel_example
# DB_USERNAME=root
# DB_PASSWORD=
# *****************************************

# *********CONEXIÓN CON LA DATABASE PRODUCCIÓN **************
# Nos conectamos a una BD ya existente en el servidor
DB_CONNECTION=mysql
DB_HOST=mariadb-servidor #nombre del contenedor
DB_PORT=3306
DB_DATABASE=bd_laravel_example # Creara una nueva tabla en la base de datos
# User y pass para acceder a la interface web phpMyAdmin
DB_USERNAME=tuUserPhpmyadmin
DB_PASSWORD=yourPassworPhpmyadminHere
# ******************************************

SESSION_DRIVER=database
SESSION_LIFETIME=120

# **************LOCAL***************
# SESSION_ENCRYPT=false
# **************PRODUCCION***************
SESSION_ENCRYPT=true #Datos de la sesión se cifren
SESSION_PATH=/

# **************LOCAL***************
#SESSION_DOMAIN=null
# **************PRODUCCION***************
SESSION_DOMAIN=.tu.dominio.es # Especifica el dominio para el cual la cookie de sesión es válida

BROADCAST_CONNECTION=log
FILESYSTEM_DISK=local
QUEUE_CONNECTION=database

CACHE_STORE=database
CACHE_PREFIX=

MEMCACHED_HOST=127.0.0.1

REDIS_CLIENT=phpredis
REDIS_HOST=127.0.0.1
REDIS_PASSWORD=null
REDIS_PORT=6379

MAIL_MAILER=log
MAIL_HOST=127.0.0.1
MAIL_PORT=2525
MAIL_USERNAME=null
MAIL_PASSWORD=null
MAIL_ENCRYPTION=null
MAIL_FROM_ADDRESS="hello@example.com"
MAIL_FROM_NAME="${APP_NAME}"

AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=
AWS_DEFAULT_REGION=us-east-1
AWS_BUCKET=
AWS_USE_PATH_STYLE_ENDPOINT=false
```

ℹ️ control + x para salir y guardar

⚠️ **No subas nunca este archivo *.env* a un repositorio público (GitHub, GitLab, etc.). Contiene datos sensibles como credenciales de acceso a la base de datos y variables de entorno.**

***
---
***

>## <a name="levantar">🚀 Levantar el contenedor</a>


```bash
docker compose up --build -d
```

### 🚪Entramos en el contenedor php  *laravel_example_php* y vamos a su consola (shell del contenedor)  

```bash
docker exec -it laravel_example_php bash
```

**🆕Una vez dentro del contenedor Generamos una nueva *KEY***

```bash
php artisan key:generate
```


***

🧹 Si algo fue mal y quieres bajar el contenedor y limpiar

```bash
docker compose down --volumes
```

***
---
***

>## <a name="fix-permissions">📝 Creamos el documento *fix-permissions.sh*</a>


📂 Entramos en el directorio *laravel_example* y creamos el *fix-permissions.sh*

### 📝 Observaciones del documento

Del 100% de los errores que da Laravel en producción, el 98% siempre son de 2 tipos, el Nº1 son *error de permisos o de propietario* en archivos o directorios y el Nº2 es *el archivo o directorio no está donde se le espera*

Para solucionar el Nº2 no tengo una medicina mágica, pero para el Nº1 si la tengo y se llama *fix-permissions.sh*

Este archivo mágico pondrá en orden todos los permisos y propietarios de archivos y directorios para que nuestro proyecto no 💥pete💥 de manera espectacular

**💡 ¿Qué hace realmente fix-permissions.sh?**

Laravel, cuando no tiene los permisos adecuados en carpetas como *storage* o *bootstrap/cache*, lanza errores 500 sin explicación clara. Y cuando los archivos no están a nombre del usuario correcto, no puedes ni instalar dependencias ni ejecutar Artisan.

Este script mágico:

1. 🧹 Limpia y pone orden.

2. 🔒 Establece los permisos justos y necesarios.

3. 🧑‍🔧 Asegura que tanto tú como el servidor web (www-data) tengan acceso correcto.

4. 🚫 Evita que Laravel 💥"explote"💥 con errores raros por falta de permisos o dueños incorrectos.

¡Ideal para evitar dolores de cabeza cuando despliegas a producción! 💣

### 🤔 ¿Cómo funciona?

1. Creas el archivo en el mismo directorio que el .yml
2. Pegas el código y lo guardas
3. Otorgar permisos de ejecución al archivo .sh
4. Lo ejecutas
5. Verificas que ahora todo está a nombre de tuUser

✅ **1. Creas el archivo en el mismo directorio que el archivo *.yml***

```bash
cd /home/tuUser/servers/laravel_example
nano fix-permissions.sh
```

**Contenido:**

```bash
#!/bin/bash
# Archivo para automatizar los permisos del proyecto

echo "Corrigiendo permisos..."

# ⚠️ ¡ SUPERIMPORTANTE !🔥Modifica *tuUser* por el usuario de tu servidor

# 1. Dar permisos correctos de dueño y grupo: El usuario será *tuUser, el grupo será www-data (el grupo de Nginx).
# Esto asegura que tu usuario tenga control de los archivos y que el servidor web (Nginx o Apache) pueda acceder correctamente a ellos
#Todos los archivos y carpetas dentro www
sudo chown -R tuUser:www-data www

# 2. Dar permisos correctos a carpetas (755), solo carpetas. El dueño puede leer/escribir/ejecutar; el grupo y otros solo leer/ejecutar.
find www -type d -exec chmod 755 {} \;

# 3. Dar permisos correctos a archivos (644), solo archivos. El dueño puede leer/escribir; el grupo y otros solo leer.
# Los archivos no son ejecutables (salvo los necesarios).
find www -type f -exec chmod 644 {} \;

# 4. Dar permisos de escritura especiales solo a storage/ y bootstrap/cache/. Recursivo (todo dentro), permitir lectura y escritura al usuario (u) y al grupo (g).
chmod -R ug+rw www/storage www/bootstrap/cache

echo "Permisos corregidos con éxito"
```

✅ **2. Otorgar permisos de ejecución al archivo .sh**

```bash
chmod +x fix-permissions.sh
```

✅ **3. Lo ejecutas**

```bash
bash fix-permissions.sh
```

✅ **4. Verificas que ahora todo está a nombre de tuUser**

```bash
ls -la

```

***
---
***

>## <a name="permisos-phpmyadmin">🔑 Dar permisos al usuario no root de MariaDB  *userNoRootPhpmyadmin*</a>


Si no usas el user root para la conexión con tu base de datos, tu usuario no root no tendrá permisos para crear la base de datos *bd_laravel_example* y nos dará un error. Para solucionarlo podemos hacer dos cosas.

1. Poner las credenciales de user root en el archivo .env de Laravel
2. La más limpia es entrar en nuestra interface phpMyAdmin, y dar permisos a nuestro usuario no root para que tenga permisos totales sobre esa base de datos solo.

### Solución 1. ✅ (Para gente cutre), no como tú.

🛑 Bajamos el contenedor

```bash
docker compose down
```

📝 Modificamos el archivo *.env* de Laravel situado en el directorio *laravel_example/www*

Modificamos:

```bash
# *********CONEXIÓN CON LA DATABASE PRODUCCIÓN **************
# Nos conectamos a una BD ya existente en el servidor
DB_CONNECTION=mysql
DB_HOST=mariadb-servidor #nombre del contenedor MariaDB
DB_PORT=3306
DB_DATABASE=bd_laravel_example # Creara una nueva tabla en la base de datos
# User y pass para acceder a la interface web phpMyAdmin
# Conexión para user no root
# DB_USERNAME=tuUserPhpmyadmin
# DB_PASSWORD=yourPassworPhpmyadminHere
# Conexión para user *root*
DB_USERNAME=root
DB_PASSWORD=youPassRootPhpmyadminHere
# ******************************************

```

🚀 Subimos el contenedor

```bash
docker compose up --build -d
```

### 🚪 Entramos en el contenedor php *laravel_example_php* y vamos a su consola (shell del contenedor)

```bash
docker exec -it laravel_example_php bash
```

**🆕 Una vez dentro del contenedor creamos la migración:**

```bash
php artisan migrate
```

**ℹ️ Te dirá si estás seguro, dale a yes y luego yes**

```
APPLICATION IN PRODUCTION.
┌ Are you sure you want to run this command? ──────────────────┐
│ Yes │
└──────────────────────────────────────────────────────────────┘

WARN The database 'bd_laravel_example' does not exist on the 'mysql' connection.
┌ Would you like to create it? ────────────────────────────────┐
│ Yes │
└──────────────────────────────────────────────────────────────┘
```

**Resultado positivo:**

```
INFO Preparing database.
Creating migration table ....................................................................................................... 43.99ms DONE

INFO Running migrations.
0001_01_01_000000_create_users_table ...........................................................................................
77.26ms DONE
0001_01_01_000001_create_cache_table ...........................................................................................
17.53ms DONE
0001_01_01_000002_create_jobs_table .......
```

🕵 Verifica que se creo exitosamente en tu interfaz de *phpMyAdmin*

### Solución 2. ✅ (Para gente pro)

1. Entra en tu interfaz PhpMyAdmin
2. Accede con el usuario root (el que tiene todos los permisos)
3. Crea la base de datos si no existe: bd_laravel_example
4. En la página de inicio ve a la pestaña *cuenta de usuarios*
5. En la fila donde sale tu usuario no root (el que tienes en el archivo .env de tu Laravel con ruta *laravel_example/www*) ve a la pestaña *Editar privilegios*
6. Ahora arriba ve a la pestaña *Bases de datos*
7. En el recuadro blanco añade el nombre de la base de datos *bd_laravel_example* y dale a continuar
8. Se abrira la pestaña de *Editar privilegios* presiona sobre el checkbox *Seleccionar todo* y continuar
9. Si todo fue bien te mostrara el siguiente mensaje:

**Si tienes dificultades para seguir los pasos,  en mis apuntes lo muestro con imágenes. Consulta  la sección: *[🔑Dar permisos al usuario no root de MariaDB  userNoRootPhpmyadmin]***

 Documento Drive

🔗[🔑Dar permisos al usuario no root de MariaDB userNoRootPhpmyadmin, tutorial Drive:](https://docs.google.com/document/d/12wyY_QgqCda8Ls375-2NF69_J9Q8g2BE_eGDx2_KYoE/edit?tab=t.0#heading=h.qzdb66mn0uxc)


🔒 También puedes ejecutar el SQL directamente desde PhpMyAdmin (pestaña SQL):

```sql
GRANT ALL PRIVILEGES ON bd_laravel_example.* TO 'tuUserPhpmyadmin'@'%';
FLUSH PRIVILEGES;
```
--- 

## 🚪 Entramos en el contenedor php *laravel_example_php* y vamos a su consola (shell del contenedor)

```bash
docker exec -it laravel_example_php bash
```

**🆕 Una vez dentro del contenedor creamos la migración:**

```bash
php artisan migrate
```

ℹ️ Te dirá si estás seguro, dale a yes y luego yes

```
APPLICATION IN PRODUCTION.
┌ Are you sure you want to run this command? ──────────────────┐
│ Yes │
└──────────────────────────────────────────────────────────────┘

WARN The database 'bd_laravel_example' does not exist on the 'mysql' connection.
┌ Would you like to create it? ────────────────────────────────┐
│ Yes │
└──────────────────────────────────────────────────────────────┘
```

**Resultado positivo:**

```
INFO Preparing database.
Creating migration table ....................................................................................................... 43.99ms DONE

INFO Running migrations.
0001_01_01_000000_create_users_table ...........................................................................................
77.26ms DONE
0001_01_01_000001_create_cache_table ...........................................................................................
17.53ms DONE
0001_01_01_000002_create_jobs_table .......
```

**🕵 Verifica que se creó exitosamente en tu interfaz de *phpMyAdmin***

**Si todo fue bien, ve a tu URL: tudominio.laravel.es y tendrías que ver la página de bienvenida de Laravel**

***
---
***
>## <a name="gitignore">📝 Crea un archivo .gitignore</a>

**🚨Este archivo es perfecto para asegurarte de nunca subir a un repositorio público cualquier documento que contenga información que nunca debe  ser expuesta al publico como por ejemplo los archivos *.env***

```bash
cd /home/tuUser/servers/laravel_example
nano .gitignore
```
¿Como añadir nuestros documentos?

```bash
# Añade el nombre del archivo y su ruta.
# .env con información del archivo .yml
.env

# .env con información del proyecto Laravel
www/.env
```
**Como tendría que quedar tu archivo .gitignore**

```bash
# ignora el .env de la raíz del proyecto (para docker-compose)
/.env

# Archivos y directorios específicos de la estructura del tutorial
/www/node_modules
/www/public/build
/www/public/hot
/www/public/storage
/www/vendor
/www/.env
/www/.env.backup
/www/storage/framework/sessions/*
/www/storage/framework/views/*.php
/www/storage/framework/cache/data/*

# Logs
/www/storage/logs/*.log
/logs
*.log

# Archivos de sistema operativo
.DS_Store
Thumbs.db

```
***
---
***
>## <a name="estructura-proyecto">🌳 Estructura del Proyecto</a>


**Asegúrate de que tu proyecto tenga esta estructura:**

```
📂 laravel_example
├── 📄 docker-compose.yml
├── 📄 .env
├── 📄 Dockerfile
├── 📄 fix-permissions.sh
├── 📄 .gitignore
├── 📂 www
│       ├── 📄 .env
│       └── 📄📂 Toda la estructura de Laravel
└──  📂 nginx
          └── 📂 data
                  └── 📂 logs
                            ├── 📄 access.log
                            ├── 📄 error.log
                            ├── 📄 laravel_example_access.log
                            └── 📄 laravel_example_error.log
```

***
---
***

>## <a name="validacion">🔎 Test de validación</a>


### ¿Cómo hacer un ping entre contenedores?

Por ejemplo, si quieres hacer un ping desde tu contenedor PHP *laravel_example_php* al contenedor de MariaDB *mariadb-servidor*:

1. **Entra en el contenedor PHP**

```bash
docker exec -it laravel_example_php bash
```

2. **Desde dentro del contenedor, haz un ping al contenedor de la base de datos usando su nombre de servicio (el que pusiste en el docker-compose.yml):**

```bash
ping mariadb-servidor
```

3. **Si tienes más contenedores, realiza la misma acción añadiendo el nombre de ese contenedor**


4. **Asegúrate que los  archivos *storage* y *bootstrap/cache* tengan permisos de lectura y escritura al usuario propietario y al grupo propietario de forma recursiva.**


```bash
chmod -R ug+rw www/storage www/bootstrap/cache
ls -la www/storage
ls -la www/bootstrap
cd www/bootstrap
ls -la cache
```

Tiene que salir de esta forma


```bash
drwxrwxr-x  5 tuUser  www-data   4096 Jun  9 16:16 storage
drwxr-xr-x  3 tuUser  www-data   4096 Jun  9 16:16 bootstrap
drwxrwxr-x  2 tuUser  www-data 4096 Jun 17 00:12 cache
```

👎Si no son correctos puedes corregirlo manualmente con:

```bash
chmod -R ug+rw www/storage www/bootstrap/cache
```


***
---
***

>## <a name="artisan">🛠️ Crear las *key*, *seeders* *migration* etc.</a>


### 🚪 Entramos en el contenedor php *laravel_example_php* y vamos a su consola (shell del contenedor)

**Comandos de Configuración Esencial (key:generate, migrate)**

```bash
docker exec -it laravel_example_php bash
```

**Una vez dentro del contenedor ejecutamos:**

```bash
php artisan key:generate
```
Esto genera una clave única para cifrar sesiones, tokens y otros datos sensibles.
Laravel no funcionará correctamente si no se genera esta clave.

```bash
php artisan migrate
```

Aplica las migraciones definidas en /database/migrations, es decir, crea las tablas necesarias en la base de datos.

**Comandos Opcionales (db:seed)**
**Si tenemos los seeder preparados ejecutamos el siguiente comando si no, no hace falta**

```bash
php artisan db:seed
```

Llena la base de datos con datos iniciales de prueba (si tienes seeders definidos en /database/seeders).

**Comandos de Desarrollo Frontend (Vite) (npm install, npm run build)**

Instala Vite como herramienta de frontend

```bash
npm install --save-dev vite
```

Compila los assets para desarrollo

```bash
npm run dev
```

Compila los assets optimizados para producción

```bash
npm run build
```

***
---
***

>## <a name="nginx-proxy">🌐 Configurar Nginx Proxy Manager</a>


1. Accede a: `http://IP-DEL-SERVIDOR:81`
2. Crea un nuevo Proxy Host:
   - **Domain Names**: `laravel.tu-dominio.es`
   - **Forward Hostname/IP**: `laravel_example_nginx`
   - **Forward Port**: `80`
   - **Scheme**: `http`
3. Opciones adicionales:
   - ✅ Block Common Exploits
   - ✅ SSL Certificate (Let’s Encrypt)
   - ✅ Force SSL
   - ✅ HTTP/2 Support

Verifica accediendo a:  
**🌐 https://laravel.tu-dominio.es**

***

### 🐛 ¿Algo ha fallado? Revisa los logs

>Si el contenedor no se levanta o tu web muestra un error 500, el primer lugar para mirar son los logs de los contenedores. Ejecuta estos comandos desde la carpeta laravel_example:

**🕵️Ver los logs del contenedor de PHP**

```bash
docker compose logs -f laravel_example_php
```


**🕵️Ver los logs del contenedor de Nginx**

```bash
docker compose logs -f laravel_example_nginx
```


***
---
***

>## <a name="https">💪 Forzar **HTTPS**</a>

### 🎨Para asegurarnos que los estilos cargar y que todo va por https  vamos al archivo con ruta:


**Ruta:** `laravel_example/www/app/Providers/AppServiceProvider.php`

```bash
nano laravel_example/www/app/Providers/AppServiceProvider.php
```

**Agregar este código en la función `boot`:**

```php
public function boot(): void
{
    //Forzamos https
    \URL::forceScheme('https');
    //Schema::defaultStringLength(191);  
}
```

***
---
***

>## <a name="imagenes">😣 Solución: Las imágenes no se cargan</a>

ℹ️ **Si tenemos cualquier imagen, estas se almacenan siempre en la ruta `storage/app/public/images` pero no es accesible si antes no hemos creado un enlace simbólico.**

**Primero, asegúrate de que tus imágenes están correctamente ubicadas en el directorio:** `storage/app/public/images`

### Cómo crear el enlace simbólico:

**✅ 1. 🚪 Entrar al contenedor de Laravel:**
```bash
docker exec -it laravel_example_php bash
```

**✅ 2. Crear el enlace simbólico correctamente**

Desde dentro de la consola de comandos del contenedor Laravel, entramos en el directorio `www` y ejecuta:

```bash
php artisan storage:link
```

ℹ️ **El mensaje correcto sería algo así como:**


```bash
The [public/storage] link has been connected to [storage/app/public].
```
***
---
***

> **Nota de seguridad**: Cambia todas las contraseñas y claves de ejemplo por valores seguros antes de usar en producción.
---

Agradecimientos especiales a ChatGPT, Claude y Gemini