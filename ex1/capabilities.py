#!/usr/bin/env python3

from abc import ABC, abstractmethod


class HealCapability(ABC):
    def __init__(self, **kwargs: object) -> None:
        super().__init__(**kwargs)

    @abstractmethod
    def heal(self, target: str) -> str:
        pass


class TransformCapability(ABC):
    def __init__(self, **kwargs: object) -> None:
        self._transformed: bool = False
        super().__init__(**kwargs)

    @abstractmethod
    def transform(self) -> str:
        pass

    @abstractmethod
    def revert(self) -> str:
        pass
