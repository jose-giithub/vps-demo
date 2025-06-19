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

# 🧰 Install system dependencies dentro del contenedor de forma global a parte para segurar que usas una versión específica y moderna.
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs

# Install npm vite
# CÓDIGO DE PRUEBAS, lo comento para que no se instale de forma global
# RUN npm install --save-dev vite

# 🧹 Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

#  🛠️Install PHP extensions
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

# Get latest Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Create system user to run Composer and Artisan Commands
RUN useradd -G www-data -u $uid -d /home/$user $user

RUN mkdir -p /home/$user/.composer && \
    chown -R $user:$user /home/$user

# Set working directory
WORKDIR /var/www