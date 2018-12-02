<?php
/**
 * Created by PhpStorm.
 * User: gbmcarlos
 * Date: 12/1/18
 * Time: 9:53 PM
 */

namespace App;

use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;

class HelloCommand extends Command {

    protected function configure() {
        $this
            ->setName('hello')
            ->setDescription('Say hello');
    }

    protected function execute(InputInterface $input, OutputInterface $output) {
        $output->writeln('Hello World');
    }

}