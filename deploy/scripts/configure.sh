#!/usr/bin/env bash

export APP_NAME=${APP_NAME:=app}
export OPTIMIZE_PHP=${OPTIMIZE_PHP:=true}
export OPTIMIZE_COMPOSER=${OPTIMIZE_COMPOSER:=true}
export XDEBUG_ENABLED=${XDEBUG_ENABLED:=false}
export XDEBUG_REMOTE_HOST=${XDEBUG_REMOTE_HOST:=10.254.254.254}
export XDEBUG_REMOTE_PORT=${XDEBUG_REMOTE_PORT:=9000}
export XDEBUG_IDE_KEY=${XDEBUG_IDE_KEY:=${APP_NAME}_PHPSTORM}

## OPTIMIZE PHP
### https://secure.php.net/manual/en/opcache.installation.php#opcache.installation.recommended
### PHP is already optimized by default (ini production values + opcache enabled + xdebug disabled),
### so if OPTIMIZE_PHP says no, then override the ini values and disable opcache (by deleting the ini file that was created by the docker-php-ext-install script)
### (xdebug will be dealt with later)
if
    [ ${OPTIMIZE_PHP} != "true" ] ;
then
        cat >>/usr/local/etc/php/php.ini <<EOL

display_errors=STDOUT
display_startup_errors=On
error_reporting=E_ALL
mysqlnd.collect_memory_statistics=Off
zend.assertions=1
log_errors=On
EOL
rm /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini ;
fi

## OPTIMIZE COMPOSER
### The autoloader is already optimized by default at build time,
### so if OPTIMIZER_COMPOSER says no, dump it again without optimizing
if
    [ ${OPTIMIZE_COMPOSER} != "true" ] ;
then
    composer dump-autoload -v ;
fi

# ENABLE XDEBUG
### Xdebug is installed but not enabled by default at build time,
### so if XDEBUG_ENABLED says yes, enable it and configure it
if
    [ ${XDEBUG_ENABLED} = "true" ] ;
then
    docker-php-ext-enable xdebug \
    &&  cat >>/usr/local/etc/php/conf.d/xdebug.ini <<EOL

xdebug.remote_host=${XDEBUG_REMOTE_HOST}
xdebug.remote_port=${XDEBUG_REMOTE_PORT}
xdebug.idekey=${XDEBUG_IDE_KEY}
xdebug.remote_enable=1
xdebug.remote_autostart=1
xdebug.remote_connect_back=off
xdebug.max_nesting_level=1500
EOL
fi
