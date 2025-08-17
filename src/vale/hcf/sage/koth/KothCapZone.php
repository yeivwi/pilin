<?php

declare(strict_types=1);


namespace vale\hcf\sage\koth;


use pocketmine\math\Vector3;

class KothCapZone {

    /** @var Vector3 */
    private Vector3 $vector_1;

    /** @var Vector3 */
    private Vector3 $vector_2;

    public function __construct(Vector3 $vector_1, Vector3 $vector_2) {
        $this->vector_1 = $vector_1;
        $this->vector_2 = $vector_2;
    }

    public function __toArray(): array {
        $vector_1 = $this->vector_1;
        $vector_2 = $this->vector_2;
        return [
            "vector_1" => [
                "x" => $vector_1->getX(),
                "y" => $vector_1->getY(),
                "z" => $vector_1->getZ()
            ],
            "vector_2" => [
                "x" => $vector_2->getX(),
                "y" => $vector_2->getY(),
                "z" => $vector_2->getZ()
            ]
        ];
    }

    public function getVector1(): Vector3 {
        return $this->vector_1;
    }

    public function getVector2(): Vector3 {
        return $this->vector_2;
    }

}