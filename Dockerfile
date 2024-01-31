# PHP NGIX BASE IMAGE 
# Build on  PHP 8.3.2RC1-fpm-alpine3.19 and NGINX 1.24.0
# https://github.com/joseluisq/alpine-php-fpm
# https://hub.docker.com/_/php/tags?page=1&name=al

#  DIGEST:sha256: 071752e874fa0f057503cc4046bdedec83c4fa2330a24274554b45a5b726182c
#  https://hub.docker.com/layers/library/php/8.3-rc-alpine3.19/images/sha256-071752e874fa0f057503cc4046bdedec83c4fa2330a24274554b45a5b726182c?context=explore

FROM php:8.3.2-alpine3.19


ENV NGINX_VERSION 1.24.0
ENV NJS_VERSION   0.8.2
ENV PKG_RELEASE   1

# install necessary alpine packages need for laravel PHP
RUN apk update  
RUN apk add $PHPIZE_DEPS 
# RUN apk add zip 
RUN apk add unzip 
RUN apk add supervisor 
RUN apk add nano 
RUN apk add curl-dev
RUN apk add dos2unix 
RUN apk add libpng-dev 
RUN apk add libzip-dev 
RUN apk add freetype-dev 
RUN apk add libxml2-dev 
RUN apk add libjpeg-turbo-dev  
RUN apk add oniguruma-dev 
RUN apk add openssl
RUN apk add pcre-dev
RUN apk add nodejs
RUN apk add npm
RUN apk add bash

# clear install cache
RUN rm -rf /var/cache/apk/*

# compile native PHP packages
# RUN docker-php-ext-install gd
# RUN docker-php-ext-install bcmath
# RUN docker-php-ext-install pcntl
RUN docker-php-ext-install ctype
RUN docker-php-ext-install curl
RUN docker-php-ext-install dom
RUN docker-php-ext-install mbstring
RUN docker-php-ext-install fileinfo
RUN docker-php-ext-install filter
RUN docker-php-ext-install pdo
RUN docker-php-ext-install session
RUN docker-php-ext-install xml
# RUN docker-php-ext-install hash (already installed in php 8.3)
    
# install PostgreSQL extensions
RUN apk add --no-cache postgresql-dev
RUN docker-php-ext-install pdo_pgsql pgsql
 
# install additional packages from PECL
RUN pecl install zip && docker-php-ext-enable zip \
    && pecl install igbinary && docker-php-ext-enable igbinary \
    && yes | pecl install msgpack && docker-php-ext-enable msgpack 


# configure packages
RUN docker-php-ext-configure gd --with-freetype --with-jpeg



# install nginx
RUN set -x \
    && nginxPackages=" \
        nginx=${NGINX_VERSION}-r${PKG_RELEASE} \
        nginx-module-xslt=${NGINX_VERSION}-r${PKG_RELEASE} \
        nginx-module-geoip=${NGINX_VERSION}-r${PKG_RELEASE} \
        nginx-module-image-filter=${NGINX_VERSION}-r${PKG_RELEASE} \
        nginx-module-njs=${NGINX_VERSION}.${NJS_VERSION}-r${PKG_RELEASE} \
    " \
    set -x \
    && KEY_SHA512="de7031fdac1354096d3388d6f711a508328ce66c168967ee0658c294226d6e7a161ce7f2628d577d56f8b63ff6892cc576af6f7ef2a6aa2e17c62ff7b6bf0d98 *stdin" \
    && apk add --no-cache --virtual .cert-deps \
    && wget -O /tmp/nginx_signing.rsa.pub https://nginx.org/keys/nginx_signing.rsa.pub \
    && if [ "$(openssl rsa -pubin -in /tmp/nginx_signing.rsa.pub -text -noout | openssl sha512 -r)" = "$KEY_SHA512" ]; then \
        echo "key verification succeeded!"; \
        mv /tmp/nginx_signing.rsa.pub /etc/apk/keys/; \
    else \
        echo "key verification failed!"; \
        exit 1; \
    fi \
    && apk del .cert-deps \
    && apk add -X "https://nginx.org/packages/alpine/v$(egrep -o '^[0-9]+\.[0-9]+' /etc/alpine-release)/main" --no-cache $nginxPackages
    
    
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log
    
# copy supervisor configuration
COPY ./supervisord.conf /etc/supervisord.conf

EXPOSE 80

# run supervisor
CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisord.conf"]
