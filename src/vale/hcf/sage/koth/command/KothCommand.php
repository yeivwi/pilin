<?php

declare(strict_types=1);


namespace vale\hcf\sage\koth\command;


use pocketmine\command\CommandSender;
use pocketmine\utils\TextFormat;
use vale\hcf\libaries\Command;
use vale\hcf\sage\koth\command\subcommand\CreateSubCommand;
use vale\hcf\sage\koth\command\subcommand\StartSubCommand;

class KothCommand extends Command {

    public function __construct() {
        $this->addSubCommand(new CreateSubCommand());
        $this->addSubCommand(new StartSubCommand());

        $this->setPermission("koth.command");
        parent::__construct("koth", "Just a koth command");
    }

    public function execute(CommandSender $sender, string $commandLabel, array $args): void {
        if(!$this->testPermission($sender)) {
            return;
        }
        if(isset($args[0])) {
            $this->getSubCommand($args[0])->execute($sender, $commandLabel, $args);
        } else {
            $sender->sendMessage(
                TextFormat::RED . "You don't know KoTH commands?\n" .
                TextFormat::GRAY . "*Use /koth help to know the KoTH's commands!"
            );
        }
    }

}