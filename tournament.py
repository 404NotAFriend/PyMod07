#!/usr/bin/env python3

from ex0 import FlameFactory, AquaFactory, CreatureFactory
from ex1 import TransformCreatureFactory, HealingCreatureFactory
from ex2 import (BattleStrategy,
                 NormalStrategy,
                 AggressiveStrategy,
                 DefensiveStrategy)


Opponent = tuple[CreatureFactory, BattleStrategy]


def battle(opponents: list[Opponent]) -> None:
    print("*** Tournament ***")

    qty_opponents = len(opponents)
    print(f"{qty_opponents} opponents involved")
    for i in range(qty_opponents):
        for j in range(i + 1, qty_opponents):
            factory1, strategy1 = opponents[i]
            factory2, strategy2 = opponents[j]
            creature1 = factory1.create_base()
            creature2 = factory2.create_base()
            print()
            print("* Battle *")
            print(creature1.describe())
            print(" vs.")
            print(creature2.describe())
            print(" now fight!")
            try:
                for strategy in strategy1.act(creature1):
                    print(strategy)
                for strategy in strategy2.act(creature2):
                    print(strategy)
            except Exception as e:
                print(f"Battle error, aborting tournament: {e}")
                break


def main() -> None:
    normal_strategy = NormalStrategy()
    aggressive_strategy = AggressiveStrategy()
    defensive_strategy = DefensiveStrategy()

    print("Tournament 0 (basic)")
    print("[ (Flameling+Normal), (Healing+Defensive) ]")
    battle([(FlameFactory(), normal_strategy),
            (HealingCreatureFactory(), defensive_strategy)])

    print()

    print("Tournament 1 (error)")
    print("[ (Flameling+Aggressive), (Healing+Defensive) ]")
    battle([(FlameFactory(), aggressive_strategy),
            (HealingCreatureFactory(), defensive_strategy)])

    print()

    print("Tournament 2 (multiple)")
    print("[ (Aquabub+Normal), (Healing+Defensive), (Transform+Aggressive) ]")
    battle([(AquaFactory(), normal_strategy),
            (HealingCreatureFactory(), defensive_strategy),
            (TransformCreatureFactory(), aggressive_strategy)])


if __name__ == "__main__":
    main()
