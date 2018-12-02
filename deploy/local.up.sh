#!/usr/bin/env bash

set -ex

cd "$(dirname "$0")"

export APP_NAME=${APP_NAME:=$(basename $(dirname $PWD))}
export APP_PATH=${APP_PATH:=/usr/local/bin/${APP_NAME}}
export APP_RELEASE=${APP_RELEASE:=latest}
export OPTIMIZE_PHP=${OPTIMIZE_PHP:=false}
export OPTIMIZE_COMPOSER=${OPTIMIZE_COMPOSER:=false}
export XDEBUG_ENABLED=${XDEBUG_ENABLED:=true}
export XDEBUG_REMOTE_HOST=${XDEBUG_REMOTE_HOST:=10.254.254.254}
export XDEBUG_REMOTE_PORT=${XDEBUG_REMOTE_PORT:=9000}
export XDEBUG_IDE_KEY=${XDEBUG_IDE_KEY:=${APP_NAME}_PHPSTORM}

docker build \
    --build-arg APP_PATH \
    -t ${APP_NAME}:latest \
    ./..

docker rm -f ${APP_NAME} || true

docker run \
    --name ${APP_NAME} \
    -it \
    -e APP_DEBUG=true \
    -e APP_NAME \
    -e OPTIMIZE_PHP \
    -e OPTIMIZE_COMPOSER \
    -e XDEBUG_ENABLED \
    -e XDEBUG_REMOTE_HOST \
    -e XDEBUG_REMOTE_PORT \
    -e XDEBUG_IDE_KEY \
    -v $PWD/../src:/var/www/src \
    -v $PWD/../vendor:/var/www/vendor \
    ${APP_NAME}:latest \
    /bin/sh -c "composer install -v --no-suggest --no-dev --no-interaction --no-ansi && ./build.sh && ./configure.sh && ${APP_NAME} $@"

