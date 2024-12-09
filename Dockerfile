FROM php:8.2 as php
WORKDIR /var/www/html

# Mod Rewrite
RUN a2enmod rewrite

# Linux Library
RUN apt-get update -y && apt-get install -y \
    libicu-dev \
    libmariadb-dev \
    unzip zip \
    zlib1g-dev \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libpq-dev \
    libcurl4-gnutls-dev

# Composer
COPY --from=composer:2.8.3 /usr/bin/composer /usr/bin/composer

# PHP Extension
RUN docker-php-ext-install pdo pdo_mysql bcmath gd
RUN docker-php-ext-configure gd --enable-gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd

# Install Laravel dependencies
COPY . /var/www/html
RUN composer install

# Set permissions (optional)
RUN chown -R www-data:www-data /var/www/html


ENV PORT=8000
ENTRYPOINT [ "docker/entrypoint.sh" ]