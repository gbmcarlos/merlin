#!/usr/bin/env bash

export APP_NAME=${APP_NAME:=app}
export APP_PATH=${APP_PATH:=/usr/local/bin}
export OPTIMIZE_PHP=${OPTIMIZE_PHP:=true}
export OPTIMIZE_COMPOSER=${OPTIMIZE_COMPOSER:=true}
export XDEBUG_ENABLED=${XDEBUG_ENABLED:=false}
export XDEBUG_REMOTE_HOST=${XDEBUG_REMOTE_HOST:=10.254.254.254}
export XDEBUG_REMOTE_PORT=${XDEBUG_REMOTE_PORT:=9000}
export XDEBUG_IDE_KEY=${XDEBUG_IDE_KEY:=${APP_NAME}_PHPSTORM}

### First build the artifact. The output will always be the app.phat file in the current directory
./box.phar build

### Then prepare the destination (make the dir and remove an existing version if any)
mkdir -p $(dirname ${APP_PATH})
rm ${APP_PATH} 2>&1 > /dev/null

### Move the artifact and give it execution permissions
mv ./app.phar ${APP_PATH}
chmod +x ${APP_PATH}
