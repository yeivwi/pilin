<?php

declare(strict_types=1);


namespace vale\hcf\sage\koth\command\subcommand;


use pocketmine\command\CommandSender;
use pocketmine\math\Vector3;
use pocketmine\utils\TextFormat;
use vale\hcf\libaries\SubCommand;
use vale\hcf\sage\koth\Koth;
use vale\hcf\sage\koth\KothCapZone;
use vale\hcf\sage\Sage;
use vale\hcf\sage\SagePlayer;

class CreateSubCommand extends SubCommand {

    public function __construct() {
        parent::__construct("create");
    }

    public function execute(CommandSender $sender, string $commandLabel, array $args): void {
        if(!$sender instanceof SagePlayer) {
            return;
        }
        if(!isset($args[1]) or !isset($args[2]) or !isset($args[3])) {
            $sender->sendMessage(
                TextFormat::RED . "You don't know KoTH commands?\n" .
                TextFormat::GRAY . "*Use /koth help to know the KoTH's commands!"
            );
            return;
        }
        /*
        if($this->checkNumber($args[2]) and $this->checkNumber($args[3])) {
            $sender->sendMessage(TextFormat::RED . "Please, type valid numbers!");
            return;
        }
        */
        $sender_vector = $sender->asVector3();
        $koth = new Koth();
        $koth->setName($args[1]);
        $koth->setCooldown((int) $args[2]);
        $koth->setTime((int) $args[2]);
        $koth->setCapZone(new KothCapZone(
            $sender_vector->add((int) $args[3], 0, (int) $args[3]),
            $sender_vector->subtract((int) $args[3], 0, (int) $args[3])
        )
        );

        Sage::getInstance()->getKothManager()->createKoth($koth);
        $sender->sendMessage(TextFormat::GREEN . "You've created the koth " . TextFormat::BLUE . $koth->getName() . TextFormat::GREEN . " correctly!");
    }

    private function checkNumber($value): bool {
        if(!is_numeric($value) or $value <= 0) {
            return false;
        }
        return true;
    }

}