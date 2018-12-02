<?php
/**
 * Created by PhpStorm.
 * User: gbmcarlos
 * Date: 12/1/18
 * Time: 8:33 PM
 */

require __DIR__ . '/../../vendor/autoload.php';

use App\HelloCommand;
use Symfony\Component\Console\Application;

$application = new Application(getenv('APP_NAME'), getenv('APP_RELEASE'));

$application->add(new HelloCommand());

$application->run();
