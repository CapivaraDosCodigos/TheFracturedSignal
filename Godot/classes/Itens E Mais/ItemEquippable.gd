extends DataItem
class_name ItemEquippable

enum Tipos { Amaldicoado, Tecnologico, Normal }
enum Slots { Defesa, Ataque, Suporte }

@export var tipo: Tipos = Tipos.Normal
@export var slot: Slots = Slots.Suporte

var Equipped: bool = false
