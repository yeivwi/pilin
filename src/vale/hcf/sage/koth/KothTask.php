<?php

declare(strict_types=1);


namespace vale\hcf\sage\koth;


use pocketmine\scheduler\Task;
use pocketmine\Server;
use pocketmine\utils\TextFormat;
use vale\hcf\sage\Sage;
use vale\hcf\sage\SagePlayer;

class KothTask extends Task {

    /** @var Koth */
    private Koth $koth;

    public function __construct(Koth $koth) {
        $this->koth = $koth;
    }

    public function onRun(int $currentTick) {
        /** @var SagePlayer $player */
        foreach(Server::getInstance()->getOnlinePlayers() as $player) {
            if(!Sage::getInstance()->getKothManager()->canPlayerCaptureKoth($player, $this->koth)) {
                $this->koth->setTime($this->koth->getCooldown());
                $this->koth->setCapturer(null);
                return;
            }
            $time = $this->koth->getTime();
            if($time <= 0) {
                $this->koth->disable($this->getTaskId());
                return;
            }
            if(!$this->koth->hasCapturer()) {
                $this->koth->setCapturer($player);
                $player->sendMessage(TextFormat::GREEN . $this->koth->getCapturer()->getName() . " está capturando el koth\nPueden editar el mensaje en la config");
            }

            $this->koth->setTime($time - 1);
        }
    }

}