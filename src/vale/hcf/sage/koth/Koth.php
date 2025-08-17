<?php

declare(strict_types=1);


namespace vale\hcf\sage\koth;


use pocketmine\Server;
use vale\hcf\sage\Sage;
use vale\hcf\sage\SagePlayer;

class Koth {

    /** @var string */
    private string $name;

    /** @var int */
    private int $cooldown;

    /** @var int */
    private int $time;

    /** @var KothCapZone */
    private KothCapZone $capzone;

    /** @var SagePlayer|null */
    private ?SagePlayer $capturer = null;

    /** @var bool */
    private bool $enabled = false;

    public function getName(): string {
        return $this->name;
    }

    public function setName(string $name): void {
        $this->name = $name;
    }

    public function getCooldown(): int {
        return $this->cooldown;
    }

    public function setCooldown(int $cooldown): void {
        $this->cooldown = $cooldown;
    }

    public function getTime(): int {
        return $this->time;
    }

    public function setTime(int $time): void {
        $this->time = $time;
    }

    public function getCapZone(): KothCapZone {
        return $this->capzone;
    }

    public function setCapZone(KothCapZone $capzone): void {
        $this->capzone = $capzone;
    }

    public function getCapturer(): ?SagePlayer {
        return $this->capturer;
    }

    public function setCapturer(?SagePlayer $capturer): void {
        $this->capturer = $capturer;
    }

    public function hasCapturer(): bool {
        return $this->capturer !== null;
    }

    public function enable(): void {
        $plugin = Sage::getInstance();
        $plugin->getServer()->broadcastMessage("El koth " . $this->name . " ha comenzado!");
        $plugin->getScheduler()->scheduleRepeatingTask(new KothTask($this), 20);
        $this->enabled = true;
    }

    public function disable(int $taskId): void {
        Server::getInstance()->broadcastMessage($this->getCapturer()->getName() . " ha capturado el koth " . $this->getName() . " felicidades");
        Sage::getInstance()->getScheduler()->cancelTask($taskId);
        $this->time = $this->cooldown;
        $this->enabled = false;
    }

    public function isEnabled(): bool {
        return $this->enabled;
    }

}