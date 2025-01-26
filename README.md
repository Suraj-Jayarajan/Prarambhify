# Prārambhify: Launchpad of Your Next App.

> Start Strong, Build Fast, Build Smart.

## Introduction

Prārambhify is a powerful, modular base engine designed to jump-start your full-stack web development projects. Whether you're creating a small-scale app or a large enterprise solution, Prārambhify provides the essential building blocks for CRUD operations, user authentication, task management, and more. With its easy-to-use structure, seamless integration of front-end and back-end components, and flexible modules, Prārambhify takes care of the foundation, so you can focus on building your vision.

## Pitch

In today’s fast-paced development world, starting from scratch can slow you down. Prārambhify removes the complexity by providing a clean, extensible engine that accelerates the creation of full-stack web applications. Featuring pre-built modules for database management, authentication, API integrations, and front-end components, Prārambhify is the perfect solution for developers who want to save time while maintaining flexibility.

Start building faster, stay focused on what matters, and leverage the power of Prārambhify to create dynamic web apps with ease. Your projects, powered by Prārambhify, are bound to go from Prārambh (beginning) to success in no time.

## Features

- In built Users & Roles
- In built ACL

# Getting Started

## Creating Docker For PHP, Niginx and Posgress from Scratch

### Step 1: Create Directories

```bash
mkdir pramabhify
cd pramabhify

# Create necessary directories
mkdir -p docker/nginx
mkdir -p docker/php
mkdir src
```

### Step 2: Create docker-compose.yml

In root directory create `docker-compose.yml` file

```yml
# docker-compose.yml
version: "3.8"

services:
  nginx:
    image: nginx:alpine
    container_name: pramabhify_nginx
    ports:
      - "8080:80"
    volumes:
      - ./src:/var/www/html
      - ./docker/nginx/default.conf:/etc/nginx/conf.d/default.conf
    depends_on:
      - php
    networks:
      - pramabhify_net

  php:
    build:
      context: ./docker/php
      dockerfile: Dockerfile
    container_name: pramabhify_php
    volumes:
      - ./src:/var/www/html
    networks:
      - pramabhify_net

  postgres:
    image: postgres:15
    container_name: pramabhify_postgres
    environment:
      POSTGRES_DB: pramabhify
      POSTGRES_USER: pramabhify
      POSTGRES_PASSWORD: secret
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - pramabhify_net

networks:
  pramabhify_net:
    driver: bridge

volumes:
  postgres_data:
    driver: local
```

### Step 3: Nginx Configuration

Create a file in `docker/nginx/default.conf`

```conf
server {
    listen 80;
    server_name localhost;
    root /var/www/html/public;
    index index.php;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
        fastcgi_pass php:9000;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }
}
```

### Step 4: Create Dockerfile

In `docker/php/Dockerfile`

```bash
FROM php:8.2-fpm

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    libpq-dev

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-install pdo_pgsql mbstring exif pcntl bcmath gd

# Get latest Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

# Set specific permissions that worked
RUN chown -R www-data:www-data /var/www/html/storage && \
    chown -R www-data:www-data /var/www/html/bootstrap/cache && \
    chmod -R 775 /var/www/html/storage && \
    chmod -R 775 /var/www/html/bootstrap/cache

```

### Step 5: Create Infrastructre

```bash
# Build and start containers
docker compose up -d

# Verify containers are running
docker ps
```

### Step 6: Create Laravel Project

```bash
# Create Laravel project using the PHP container
docker compose exec php composer create-project laravel/laravel .
```

### Step 7: Update Laravel Env

```bash
# Copy example env file
cp src/.env.example src/.env

# Update these values in .env
DB_CONNECTION=pgsql
DB_HOST=postgres
DB_PORT=5432
DB_DATABASE=pramabhify
DB_USERNAME=pramabhify
DB_PASSWORD=secret
```

### Step 8: Generate Application Key and run migrations

```bash
docker compose exec php php artisan key:generate
```

and then

```bash
docker compose exec php php artisan migrate
```

Your application should now be accessible at:

- Website: http://localhost:8080
- Database: localhost:5432 (accessible via any PostgreSQL client)

Important Information:

The project structure will be:

```bash
pramabhify/
├── docker/
│   ├── nginx/
│   │   └── default.conf
│   └── php/
│       └── Dockerfile
├── src/
│   └── (Laravel files will be here)
└── docker-compose.yml
```
