# 🗄️ Cómo subir una base de datos MariaDB e interfaz web PhpMyAdmin dockerizada 🐳

Montar una base de datos SQL para nuestro servidor usando MariaDB y para manipularla una interfaz web PhpMyAdmin con usuario y contraseña.

**Autor**: Jose Rodríguez  

## Redes sociales 🌐

**Portfolio**🔗[Enlace portfolio:](https://portfolio.jose-rodriguez-blanco.es)
**LinkedIn**🔗[Enlace LinkedIn:](https://www.linkedin.com/in/joseperfil/)
**GitHub**🔗[Enlace GitHub:](https://github.com/jose-giithub)

***
---
***

## 📋Índice

- [🤔 ¿Qué encontraremos en este tutorial?](#que-encontraremos-en-este-tutorial)
- [🚧 Requisitos previos](#requisitos-previos)
- [⚠️ Tener en cuenta](#tener-en-cuenta)
- [📂 Creamos la estructura para nuestra base de datos](#creamos-la-estructura-para-nuestra-base-de-datos)
- [📝 Creamos el documento docker-compose.yml](#creamos-el-documento-docker-composeyml)
- [🔒 Archivo env para las credenciales](#archivo-env-para-las-credenciales)
- [🐳 Levantamos el contenedor](#levantamos-el-contenedor)
- [🌐 Configurar Nginx Proxy Manager](#configurar-nginx-proxy-manager)
- [📂 Estructura del proyecto final](#estructura-del-proyecto-final)
- [😫 Qué hacer si no te deja entrar](#que-hacer-si-no-te-deja-entrar)
- [🖋 Cambio de contraseña en PhpMyAdmin](#cambio-de-contrasena-en-phpmyadmin)
- [🧠 Extras](#extras)


***
---
***


## 🤔 ¿Qué encontraremos en este tutorial?

Guía del paso a paso para levantar un servicio de base de datos MariaDB junto con una interfaz web PhpMyAdmin usando Docker y Docker Compose, de forma segura y organizada.

---
## 🧰 Si quieres uno tutorial mas completo y detallado lo tienes en: 

🔗[🗄️Como subir una Base de datos MariaDB e interface web phpMyAdmin Dockerizado🐳, tutorial Drive:](https://docs.google.com/document/d/1iteWeHyYgD4lyjB1zA_IN_j3bb_SpFukxwEdetI4Eo8/edit?usp=sharing)

***
---
***

## 🚧 Requisitos previos

1. ✅ Tener un servidor Linux (se usó Ubuntu 24.04.2 LTS)
2. ✅ Tener dominio y subdominios configurados
3. ✅ Conocer la IP pública del servidor
4. ✅ Tener un usuario no root con permisos `sudo` y en el grupo `docker`
5. ✅ Tener Docker y Docker Compose instalados
6. ✅ Tener configurado Nginx Proxy Manager y saber que funciona

> 💡 **Tip**: Puedes encontrar información sobre la configuración inicial del VPS en:

- Documento Drive

🔗[Configurar VPS desde 0 paso a paso, tutorial Drive:](https://docs.google.com/document/d/1RMoX8kUR3lRntgdGNtjpnFPkNULrNoSefXUzDBEabOE/edit?usp=sharing)

- Tutorial en GhiHab

🔗[Configurar VPS desde 0 paso a paso, tutorial GitHab:](https://github.com/jose-giithub/vps-demo/tree/main)

***
---
***

## ⚠️ Tener en cuenta

> ⚠️**Todo se hace con usuario no root**

```bash
su tuUsuario
```

***
---
***

## 📂 Creamos la estructura para nuestra base de datos

```bash
cd /home/tuUser/servers
mkdir database
cd database
mkdir mariadb
```

Ruta final: `/home/tuUser/servers/database/mariadb`

***
---
***

## 📝 Creamos el documento `docker-compose.yml`

```bash
cd /home/tuUser/servers/database
nano docker-compose.yml
```

Contenido del archivo:

```yml
services:
  # 📦 CONTENEDOR 1. 🗄 Base de datos MariaDB
  mariadb:
    image: mariadb:10.6
    container_name: mariadb-servidor
    restart: unless-stopped
    environment:
      MYSQL_ROOT_PASSWORD: ${userRoot} # ℹ️ Esta variable se la pasaremos desde el archivo .env
      MYSQL_DATABASE: ${dbName} # ℹ️ Esta variable se la pasaremos desde el archivo .env
      MYSQL_USER: ${userApp} # ℹ️ Esta variable se la pasaremos desde el archivo .env
      MYSQL_PASSWORD: ${userPass} # ℹ️ Esta variable se la pasaremos desde el archivo .env
    volumes:
      - ./mariadb:/var/lib/mysql
    expose:
      - "3306"
    networks:
      - proxiable

  # 📦 CONTENEDOR 2. 🌐 Interfaz web PhpMyAdmin
  phpmyadmin:
    image: phpmyadmin/phpmyadmin:latest
    container_name: phpmyadmin-servidor
    restart: unless-stopped
    environment:
      PMA_HOST: mariadb
    networks:
      - proxiable

networks:
  proxiable:
    external: true
```

***
---
***

## 🔒 Archivo `.env` para las credenciales

Creamos el archivo oculto `.env` junto al `docker-compose.yml`:

```bash
nano .env
```

Contenido:

```bash
#  Usuario root será root, es el usuario por defecto
# Contraseña para el usuario root de MariaDB del "MYSQL_ROOT_PASSWORD" en el .yml
userRoot=MiRootSeguro123

# Nombre de una base de datos inicial. Para "MYSQL_DATABASE" en el .yml
dbName=miPrimerabd

# #  Usuario no root 

 # Tu usuario para entrar en la interface phpMyAdmin
# Hace referencia a *MYSQL_USER* en el .yml 
userApp=tuUserApp

# Contraseña de tu usuario (no root), para entrar en la interface phpMyAdmin
# Hace referencia a "MYSQL_PASSWORD" en el .yml
userPass=claveSegura123
```

Protegemos el archivo:

```bash
chmod 600 .env
```

> ⚠️ **Nunca subas este archivo a GitHub público. Añádelo a `.gitignore`.**

***
---
***

## 🐳 Levantamos el contenedor

```bash
docker compose up -d
```

***
---
***

## 🌐 Configurar Nginx Proxy Manager

1. Accede a: `http://IP-DEL-SERVIDOR:81`
2. Crea un nuevo Proxy Host:
   - **Domain Names**: `database.tu-dominio.es`
   - **Forward Hostname/IP**: `phpmyadmin-servidor`
   - **Forward Port**: `80`
   - **Scheme**: `http`
3. Opciones adicionales:
   - ✅ Block Common Exploits
   - ✅ SSL Certificate (Let’s Encrypt)
   - ✅ Force SSL
   - ✅ HTTP/2 Support

Verifica accediendo a:  
**🌐 https://database.tu-dominio.es**

***
---
***

## 📂 Estructura del proyecto final

```text
/📂home/tuUser/servers/database/
├── 📄docker-compose.yml
├── 📄.env
└── 📂mariadb/
    └── 📂/📄(datos internos creados automáticamente)
```

***
---
***


## 😫 ¿Qué hacer si no te deja entrar?

>Puede ser que la ayas cagado bien y no recuerdas la contraseña o el contenedor lo subiste con algún usuario o contraseña en unas preúvas anteriores o alguna línea similar y ahora añades el user y la pass y te da error.

Pasos para solucionarlo:

1. **Parar contenedor**:

```bash
docker compose down
   ```

2. **Borrar volumenes antiguos**:
```bash
   docker volume prune
   ```

3. **Eliminar carpeta de datos**:
```bash
   sudo rm -rf mariadb
   ```

4. **(Opcional) Borrar imágenes viejas**:
 ```bash
   docker images
   docker rmi ID-IMAGEN-MARIADB
   docker rmi ID-IMAGEN-PHPMYADMIN
   ```

5. **Levantar de nuevo**:
```bash
   docker compose up -d
   ```

***
---
***

## 🖋 Cambio de contraseña en PhpMyAdmin

1. Accede a PhpMyAdmin con tu usuario
2. En la pantalla inicial, busca **Configuraciones generales > Cambio de contraseña**
3. Cambia y guarda
4. ¡No olvides tu nueva contraseña! ☠️

***
---
***

## 🧠 Extras

>Para cambiar la contraseña por terminal:

```bash
docker exec -it mariadb-servidor mysql -u root -p
```

Dentro del cliente:

```sql
ALTER USER 'tuUserApp'@'%' IDENTIFIED BY 'nuevaClave';
FLUSH PRIVILEGES;
```

***
---
***


> **Nota de seguridad**: Cambia todas las contraseñas y claves de ejemplo por valores seguros antes de usar en producción.
---

Agradecimientos especiales a ChatGPT  