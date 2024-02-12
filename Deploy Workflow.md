# Laravel + Vite + Vue Dockerizing
- Creating a docker file for each service
 - ### For this application we have a 3 services 
 1. PHP service - to run our application 
 2. nginx service - reverse proxy with vite and vue build files
 3. mysql service - for db setup and data storing (This can be setup seperately in a production environment so it can be clustered seperately)
### Workflow Idea
The current idea for the workflow is that after the environment is setup, the deployment team can do a test on the server or after the creation of the containers.
#### If the Environment is setup correctly 
##### Windows
run on powershell
```bash
./build.ps1
```

##### Linux
run
```bash
bash build.sh
```
***___we are running it with bash to standardize output of the command___***

### Docker Compose File
```yaml
version: "3"
services:
    mysql:
        image: mariadb:10.6
        container_name: mysql
        restart: unless-stopped
        tty: true
        ports:
            - 3307:3306
        environment:
            MYSQL_DATABASE: ${DB_DATABASE}
            MYSQL_USER: ${DB_USERNAME}
            MYSQL_PASSWORD: ${DB_PASSWORD}
            MYSQL_ROOT_PASSWORD: ${DB_PASSWORD}
            SERVICE_TAGS: dev
            SERVICE_NAME: mysql
        volumes:
            - todo-mysql-data:/var/lib/mysql
        networks:
            - default
    php-fpm:
        build:
            context: .
            dockerfile: /docker/php/DOCKERFILE
        depends_on:
            - mysql
        container_name: php-fpm
        restart: unless-stopped
        user: www-data #Use www-data user for production usage
        volumes:
            #Project root
            - ./:/var/www/html
        networks:
            - default #if you're using networks between containers
    #Nginx server
    nginx-server:
        build:
            context: .
            dockerfile: /docker/nginx/DOCKERFILE
        depends_on:
            - php-fpm
        container_name: nginx-server
        restart: unless-stopped
        ports:
            - 9669:80
        volumes:
            #Project root
            - ./:/var/www/html
        environment:
            - DOCUMENT_ROOT=/var/www/html/public
            - CLIENT_MAX_BODY_SIZE=20M
            - PHP_FPM_HOST=php-fpm:9000
        networks:
            - default
volumes:
  todo-mysql-data:
    external: false
```

### Services
#### PHP
- since we needed to create an image to run our application we used this service in the compose file is linked to a dockerfile
```dockerfile
  FROM php:8.3-fpm
  COPY ./ ./
    # removing the vendor folder
    RUN rm -rf vendor

    # updating the packages in the image, and cleaning the obsolete packages 
    RUN apt-get update -y && apt-get upgrade -y && apt-get autoremove -y && apt-get autoclean -y

    # Installing php extensions using php-extension installer
    COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/
    RUN install-php-extensions @composer-2.2.4
    # Here we specify what extensions are needed for this application to run
    RUN install-php-extensions pdo_mysql sockets zip


    # Create folders required by Laravel and giving permission to the created folder
    RUN mkdir -p bootstrap/cache storage/app storage/framework/cache storage/framework/sessions storage/framework/views \
    storage/logs secrets \
    && chown -R www-data /var/www /var/www/html \
    && composer install --ignore-platform-reqs \
    && php artisan storage:link \
    && rm -rf docker

    USER www-data
    VOLUME /var/www/html/storage
    WORKDIR /var/www/html

    EXPOSE 9000

```
- in this dockerfile we are preparing and creating an image to run the source code. As a base image this is using the php-fpm with php version 8.3
  
#### Nginx Server

```dockerfile
FROM node:18.16.0 as build-stage

WORKDIR /app

# preparing the vite app for production
COPY . .
RUN npm install
RUN npm run build



FROM nginx:alpine


WORKDIR /var/www/html/public
# copying the built app to the nginx server
COPY --from=build-stage ./app/public /var/www/html/public

# copying the nginx configuration file
COPY ./docker/nginx/app.conf /etc/nginx/conf.d/app.conf
#creating the storage folder and linking it to the public folder
RUN mkdir -p /storage/app/public \
    && touch /storage/app/public/.ignore \
    && ln -s /storage/app/public storage

EXPOSE 80


```

- here there is a two part build process
  - firstly we are creating the vite production assets with a base image from node js
  - then we are assigning that created image a name ***build-stage***
- When we are creating the nginx server we are copying the build file from that app to the folder on the nginx server
##### Nginx conifiguration
```nginx
server {
    listen       80;
    server_name  localhost;
    root         /var/www/html/public;

    access_log /var/log/nginx/access.log;
    error_log  /var/log/nginx/error.log;
    index index.php;

    ## PHP server routing
    location ~ \.php$ {
    fastcgi_split_path_info ^(.+\.php)(/.+)$;
    fastcgi_pass php-fpm:9000;
    fastcgi_index index.php;
    include fastcgi.conf;
    }
    ## Entry point to the vite application
    location / {
    try_files $uri $uri/ /index.php?$query_string;
    }
}
```
This is the configuration for the nginx server to distribute traffic from this server