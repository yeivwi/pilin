<?php

declare(strict_types=1);


namespace vale\hcf\sage\koth\command\subcommand;


use pocketmine\command\CommandSender;
use vale\hcf\libaries\SubCommand;
use vale\hcf\sage\Sage;
use vale\hcf\sage\SagePlayer;

class StartSubCommand extends SubCommand {

    public function __construct() {
        parent::__construct("start");
    }

    public function execute(CommandSender $sender, string $commandLabel, array $args): void {
        if(!$sender instanceof SagePlayer) {
            return;
        }
        if(!isset($args[1])) {
            return;
        }
        $koth = Sage::getInstance()->getKothManager()->getKoth($args[1]);

        $koth->enable();

    }

}