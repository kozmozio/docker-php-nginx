# Docker PHP Nginx
This repository contains a Docker configuration for running PHP with Nginx. Used as base image and wil be extended for Laravel Wordpress or other PHP installations.

Docker Image is here : https://hub.docker.com/

## Getting Started
To get started, follow these steps:

1. Clone this repository: `git clone https://github.com/kozmozio/docker-php-nginx.git`

2. Change into the project directory: `cd docker-php-nginx`

3. Build PHP Nginx Base image localy and serve 
  
  ~~~
    docker build -f Dockerfile -t kozmozio/php-nginx-base -t kozmozio/php-nginx-base:8.3 . --no-cache
  ~~~
  * 8.3 refers to PHP Version 

4. Run the Docker container: `docker run -p 8080:80 my-php-app`

5. Open your browser and visit `http://localhost:8080`

6. Push image to Docker Hub 
~~~
    docker tag kozmozio/php-nginx-base:8.3 kozmozio/php-nginx-base:8.3 
    docker push kozmozio/php-nginx-base:8.3
~~~

## Extending

This image base image for PHP projects and will be extended in other Dockerfile or Docker compose file.

FROM kozmozio/php-nginx-base:8.3
...
... Add your customizations here
...


## Contributing
Contributions are welcome! 

