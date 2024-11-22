from pydantic import BaseModel
from enum import Enum

class Item(BaseModel):
    id: int
    system: str
    account: str
    user: str | None = None
    privilege: str | None = None
    note: str | None = None

class Source(Enum):
    Nil = "Nil"
    VM = "vm"
    Git = "git"