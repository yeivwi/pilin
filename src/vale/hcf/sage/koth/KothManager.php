<?php

declare(strict_types=1);


namespace vale\hcf\sage\koth;


use pocketmine\math\Vector3;
use pocketmine\utils\Config;
use vale\hcf\sage\Sage;
use vale\hcf\sage\SagePlayer;

class KothManager {

    /** @var Koth[] */
    private array $koths = [];

    public function __construct() {
        $this->init();
    }

    public function getKoths(): array {
        return $this->koths;
    }

    public function getKoth(string $name): Koth {
        return $this->koths[$name];
    }

    public function createKoth(Koth $koth): void {
        $this->koths[$koth->getName()] = $koth;
    }

    public function deleteKoth(Koth $koth): void {
        unset($this->koths[$koth->getName()]);
    }

    public function init(): void {
        foreach($this->getKothConfig()->getAll() as $koth_data) {
            $koth = new Koth();
            $koth->setName($koth_data["name"]);
            $koth->setCooldown($koth_data["cooldown"]);
            $koth->setTime($koth_data["cooldown"]);
            $koth->setCapZone($this->getCapZoneFormArray($koth_data["capzone"]));
            $this->createKoth($koth);
        }
    }

    public function save(): void {
        foreach($this->getKoths() as $koth) {
            $config = $this->getKothConfig();
            $config->set("koths", [
                "name" => $koth->getName(),
                "cooldown" => $koth->getCooldown(),
                "capzone" => $koth->getCapZone()->__toArray()
            ]);
            $config->save();
        }
    }

    private function getCapZoneFormArray(array $data): KothCapZone {
        $vector_1 = $data["vector_1"];
        $vector_2 = $data["vector_2"];
        return new KothCapZone(
          new Vector3($vector_1["x"], $vector_1["y"], $vector_1["z"]),
          new Vector3($vector_2["x"], $vector_2["y"], $vector_2["z"])
        );
    }

    public function canPlayerCaptureKoth(SagePlayer $player, Koth $koth): bool {
        $has_capturer = $koth->hasCapturer();
        $in_capzone = $this->isPlayerInCapzone($player, $koth->getCapZone());
        if(!$has_capturer and $in_capzone or $has_capturer and $player->getName() === $koth->getCapturer()->getName() and $in_capzone) {
            return true;
        }
        return false;
    }

    public function isPlayerInCapzone(SagePlayer $player, KothCapZone $capzone): bool {
        $player_vector = $player->asVector3();
        $capzone_vector_1 = $capzone->getVector1();
        $capzone_vector_2 = $capzone->getVector2();
        if(
            $player_vector->getZ() <= $capzone_vector_1->getZ() and
            $player_vector->getZ() >= $capzone_vector_2->getZ() and
            $player_vector->getX() >= $capzone_vector_2->getX() and
            $player_vector->getX() <= $capzone_vector_1->getX()
        ) {
            return true;
        }
        return false;
    }

    private function getKothConfig(): Config {
        return new Config(Sage::getInstance()->getDataFolder() . "koths.yml", Config::YAML);
    }

}