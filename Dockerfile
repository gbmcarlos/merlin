FROM php:7.2-cli-alpine3.8

LABEL maintainer="gbmcarlos@ekar.me"

## SYSTEM DEPENDENCIES
### vim and bash are utilities, so that we can work inside the container
### $PHPIZE_DEPS contains the dependencies to use phpize, which is required to install with pecl
RUN     apk update \
    &&  apk add \
            bash vim \
            $PHPIZE_DEPS

## PHP EXTENSIONS
### Install xdebug but don't enable it, it will be enabled at run time if needed
RUN     set -ex \
    &&  pecl install \
            xdebug-2.6.1 \
    &&  docker-php-ext-install \
            opcache

WORKDIR /var/www

## COMPOSER
### Install composer by copying the binary from composer's official image (compressed multi-stage)
### So far, we are just going to install the dependencies, so no need to dump the autoloader yet
### At the end, remove the root's composer folder that was used to install and use prestissimo
COPY --from=composer:1.7.2 /usr/bin/composer /usr/bin/composer
COPY ./composer.* ./
RUN     composer global require -v --no-suggest --no-interaction --no-ansi hirak/prestissimo:0.3.8 \
    &&  composer install -v --no-autoloader --no-suggest --no-dev --no-interaction --no-ansi \
    &&  rm -rf /root/.composer

## CONFIGURATION FILES
### php, php-fpm, and nginx config files
### Even though it would be better to have this layer (cheap) as far as possible down the stack of layers,
### the next one checks for PHP settings, so let's copy the configuration files now
COPY ./deploy/config/* /usr/local/etc/php/

## BOX
### Install Box as phar
### https://github.com/box-project/box2
RUN     curl -LSs https://box-project.github.io/box2/installer.php | php \
    &&  chmod 775 box.phar
COPY box.json box.json

## SOURCE CODE
COPY ./src ./src

## COMPOSER AUTOLOADER
### Now that we've copied the source code, dump the autoloader
### By default, optimize the autoloader
RUN composer dump-autoload -v --classmap-authoritative --no-dev --no-interaction --no-ansi

## SCRIPTS
### Make sure all scripts have execution permissions
COPY ./deploy/scripts/* ./
RUN chmod +x ./*.sh

## ENV VARS
ARG APP_PATH=/usr/local/bin/app
ENV APP_PATH=$APP_PATH
ARG APP_RELEASE=latest
ENV APP_RELEASE=$APP_RELEASE

## BUILD
### Build the command line application binary with Box
RUN ./build.sh

CMD $APP_PATH help
