#!/usr/bin/env bash

set -ex

cd "$(dirname "$0")"

export APP_NAME=${APP_NAME:=$(basename $(dirname $PWD))}
export APP_PATH=${APP_PATH:=/usr/local/bin/${APP_NAME}}
export APP_RELEASE=${APP_RELEASE:=$(git rev-parse HEAD)}
export OPTIMIZE_PHP=${OPTIMIZE_PHP:=true}
export OPTIMIZE_COMPOSER=${OPTIMIZE_COMPOSER:=true}
export XDEBUG_ENABLED=${XDEBUG_ENABLED:=false}
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
    ${APP_NAME}:latest \
    ${APP_NAME} "$@"
