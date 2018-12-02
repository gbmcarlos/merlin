# Merlin

## Requirements
* Docker

## Installation
TL;DR: run `./deploy/up.sh`.

This command line application is dockerized, which means that it runs inside a Docker container. Installing the dependencies, configuring the run time environment and running the application, all happens inside the container.

To spin up the container (build the Docker image and run the Docker container) just run `./deploy/up.sh`. Any arguments passed to this script will be proxied to command line application. so `./deploy/up.sh hello --help` will become `merlin hello --help` inside the container.

## Development
TL;DR: run `./deploy/local.up.sh`.

When developing in a local environment, just run `./deploy/local.up.sh`.

The passing of arguments works the same was as the `up.sh` script.

This script will build the image and run the container, but mounting volumes for the source and vendor folders.

Also, before running the application, this scripts will install the dependencies again (to override whatever was on the mounted vendor volume), build the application again, and configure the run time environment (by running `./configure.sh`)

## Start-up scripts provided
* `up.sh`: (supposed to run on the host, located in `deploy/`) to deploy the application with configuration values optimized for production using environment variables.
* `local.up.sh`: (supposed to run on the host, located in `deploy/`) to deploy the application in your development environment, mounting volumes for your source code and vendor libraries, to work comfortably.
* `build.sh`: (supposed to run inside the Docker container, located in `/var/www`) builds the application artifact using [Box](https://github.com/box-project/box2), configured by `box.json`.
* `configure.sh`: (supposed to run inside the Docker container, located in `/var/www`) it configures the run-time environment according to the `OPTIMIZE_` and `XDEBUG_` environment variables.

## Environment variables available
These environment variables are given a default value in the `up.sh` and `local.up.sh` (host) scripts, and also in the `configure.sh` and `entrypoint.sh` (container) scripts. The default value in any of the host scripts will override the default value in the container scripts.

|       ENV VAR        |                 Default value                 |         Description       |
| -------------------- | --------------------------------------------- | ------------------------- |
| APP_NAME             | Name of the project's root folder (`localhost` in the container scripts)  | Used to name the docker image and docker container from the `up.sh` files, and as the name server in nginx. |
| APP_RELEASE          | Current commit's hash (`latest` in `local.up.sh`)                         | Used at build time to persist the environment variable into the image. When deploying with `up.sh`, it's the hash of the current commit (`HEAD`) |
| APP_PATH             | /usr/local/bin/`APP_NAME`                                                 | Path to the application binary inside the container |
| OPTIMIZE_PHP         | `true` (`false` in `local.up.sh`)                                         | Sets PHP's configuration values about error reporting and display [the right way](https://www.phptherightway.com/#error_reporting) and enables [OPCache](https://secure.php.net/book.opcache). |
| OPTIMIZE_COMPOSER    | `true` (`false` in `local.up.sh`)                                         | Optimizes Composer's autoload with [Optimization Level 2/A](https://getcomposer.org/doc/articles/autoloader-optimization.md#optimization-level-2-a-authoritative-class-maps). |
| OPTIMIZE_ASSETS      | `true` (`false` in `local.up.sh`)                                         | Optimizes assets compilation. |
| BASIC_AUTH_ENABLED   | `true` (`false` in `local.up.sh`)                                         | Enables Basic Authentication with Nginx. |
| BASIC_AUTH_USERNAME  | admin                                                                     | If `BASIC_AUTH_ENABLED` is `true`, it will be used to run `htpasswd` together with `BASIC_AUTH_PASSWORD` to encrypt with bcrypt (cost 10). |
| BASIC_AUTH_PASSWORD  | `APP_NAME`_password                                                       | If `BASIC_AUTH_ENABLED` is `true`, it will be used to run `htpasswd` together with `BASIC_AUTH_USERNAME` to encrypt with bcrypt (cost 10). |
| XDEBUG_ENABLED       | `false` (`true` in `local.up.sh`)                                         | Enables Xdebug inside the container. |
| XDEBUG_REMOTE_HOST   | 10.254.254.254                                                            | Used as the `xdebug.remote_host` PHP ini configuration value. |
| XDEBUG_REMOTE_PORT   | 9000                                                                      | Used as the `xdebug.remote_port` PHP ini configuration value. |
| XDEBUG_IDE_KEY       | `APP_NAME`_PHPSTORM                                                       | Used as the `xdebug.idekey` PHP ini configuration value. |

## Updating dependencies
Whenever you want to update the dependencies, delete the lock files (`composer.lock` and `package-lock.json`), run the project again (with `up.sh` or `local.up.sh`)(this will update the dependencies and write the lock file inside the container) and extract the lock file from inside the container with:
```bash
docker cp merlin:/var/www/composer.lock .
```

## Xdebug support
Even though the project runs inside a Docker container, it still provides support for debugging with Xdebug. By telling Xdebug the remote location of your IDE and configuring this one to listen to certain port, they can communicate with one another.

Use the `XDEBUG_` environment variables to configure your project's debugging.

### Xdebug for PhpStorm on Mac
Check [this documentation](https://gist.github.com/gbmcarlos/77614789be8a6ecc1dc3aec4b49c07bc), sections "Configuring PhpStorm" and "Configuring MacOS". to configure your IDE and system.
Use the `XDEBUG_` environment variables and the path mappings:
* project's root folder -> `APP_PATH`

## Built-in Stack
* [Alpine Linux 3.8 (:3.8)](https://hub.docker.com/_/alpine/)
* [PHP 7.2(:7.2-cli-alpine3.8)](https://hub.docker.com/_/php/)
* [Xdebug 2.6.1](https://xdebug.org/)
* [Symfony Console Component 4.2](https://symfony.com/doc/4.2/components/console.html)
