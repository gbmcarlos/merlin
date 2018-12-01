#!/usr/bin/env bash

export APP_NAME=${APP_NAME=localhost}
export OPTIMIZE_PHP=${OPTIMIZE_PHP:=true}
export OPTIMIZE_COMPOSER=${OPTIMIZE_COMPOSER:=true}
export XDEBUG_ENABLED=${XDEBUG_ENABLED:=false}
export XDEBUG_REMOTE_HOST=${XDEBUG_REMOTE_HOST:=10.254.254.254}
export XDEBUG_REMOTE_PORT=${XDEBUG_REMOTE_PORT:=9000}
export XDEBUG_IDE_KEY=${XDEBUG_IDE_KEY:=${APP_NAME}_PHPSTORM}

# Configure according to the OPTIMIZE_ BASIC_AUTH_ and XDEBUG_ env vars
/bin/sh ./configure.sh

php \
    -c /usr/local/etc/php.ini \
    /var/www/src/bootstrap/app.php
