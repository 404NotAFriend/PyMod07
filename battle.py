#!/usr/bin/env python3

from ex0 import FlameFactory, AquaFactory
from ex0.creature_factory import CreatureFactory


def test_factory(factory: CreatureFactory) -> None:
    print("Testing factory")
    base = factory.create_base()
    print(base.describe())
    print(base.attack())
    evolved = factory.create_evolved()
    print(evolved.describe())
    print(evolved.attack())


def battle(factory1: CreatureFactory, factory2: CreatureFactory) -> None:
    print("Testing battle")
    base1 = factory1.create_base()
    base2 = factory2.create_base()
    print(base1.describe())
    print(" vs.")
    print(base2.describe())
    print(" fight!")
    print(base1.attack())
    print(base2.attack())


if __name__ == "__main__":
    magma = FlameFactory()
    aqua = AquaFactory()
    test_factory(magma)
    print()
    test_factory(aqua)
    print()
    battle(magma, aqua)
