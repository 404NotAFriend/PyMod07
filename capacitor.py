#!/usr/bin/env python3


from ex0 import CreatureFactory
from ex1 import (
    HealingCreatureFactory,
    TransformCreatureFactory,
    HealCapability,
    TransformCapability
)
from typing import cast


def test_healing_factory(factory: CreatureFactory) -> None:
    print("Testing Creature with healing capability")
    print(" base:")
    base = factory.create_base()
    print(base.describe())
    print(base.attack())
    print(cast(HealCapability, base).heal("small"))
    print(" evolved:")
    evolved = factory.create_evolved()
    print(evolved.describe())
    print(evolved.attack())
    print(cast(HealCapability, evolved).heal("large"))


def test_transform_factory(factory: CreatureFactory) -> None:
    print("Testing Creature with transform capability")
    print(" base:")
    base = factory.create_base()
    print(base.describe())
    print(base.attack())
    print(cast(TransformCapability, base).transform())
    print(base.attack())
    print(cast(TransformCapability, base).revert())
    print(" evolved:")
    evolved = factory.create_evolved()
    print(evolved.describe())
    print(evolved.attack())
    print(cast(TransformCapability, evolved).transform())
    print(evolved.attack())
    print(cast(TransformCapability, evolved).revert())


def main() -> None:
    test_healing_factory(HealingCreatureFactory())
    print()
    test_transform_factory(TransformCreatureFactory())


if __name__ == "__main__":
    main()
