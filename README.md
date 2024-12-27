# i@nseo docker image

## What is i@nseo?

[i@nseo](https://www.ianseo.net/) is a software for managing archery tournaments, sponsored by the Italian Archery Federation (FITARCO), distributed worldwide for free and translated in several languages. 

![](https://www.ianseo.net/Release/ianseo_web.png)

## This image

### Description

Provides i@nseo version 2024-12-08 "Experience is the teacher of all things (Gaius Iulus Caesar)" rev 7 and is based on Alpine Linux 3.21, therefore it is very small on footprint.

### How to use it

Starting the container is as easy as running:

	docker run -d -p 80:80 flippolis/ianseo:latest

This requires to have a MariaDB instance up and running. It is possible to run the container via docker compose as well. For configuration persistence it is better to use a docker volume which will include the i@nseo configuration after the initial setup. This is an example of a docker compose file assuming you have an external MariaDB instance:

    services:
          ianseo:
                image: flippolis/ianseo:latest
                container_name: ianseo
                restart: unless-stopped
                ports:
                    - 80:80
                volumes:
                    - ianseo_web:/var/www/localhost/htdocs/ianseo
    
    volumes:
        ianseo_web:

An "all in one" solution includes MariaDB with healthcheck:

    services:
          ianseo:
                image: flippolis/ianseo:latest
                container_name: ianseo
                restart: unless-stopped
                ports:
                    - 80:80
                volumes:
                    - ianseo_web:/var/www/localhost/htdocs/ianseo
                depends_on:
                    db:
                        condition: service_healthy
                    
        db:
            image: mariadb:11.6
            container_name: ianseo_db
            restart: unless-stopped
            volumes:
                - ianseo_db:/var/lib/mysql
            environment:
                MARIADB_ROOT_PASSWORD: ROOT_PASSWORD
                MARIADB_DATABASE: ianseo
                MARIADB_USER: ianseo
                MARIADB_PASSWORD: IANSEO_DB_PASSWORD
            healthcheck:
                test: [ "CMD", "healthcheck.sh", "--connect", "--innodb_initialized" ]
                start_period: 1m
                start_interval: 10s
                interval: 1m
                timeout: 5s
                retries: 3
          
    volumes:
        ianseo_web:
        ianseo_db:

Please change `MARIADB_ROOT_PASSWORD` and `MARIADB_PASSWORD` at your preference. This last solution will also initialize an empty database and user both named "ianseo". On i@nseo setup you can just provide `db` as the database host.

Then run either files with

    docker compose up -d

### Repository

Files for building the image and docker compose examples are hosted on this [GitHub repo](https://github.com/flippolis/ianseo).
