#InventoryData.gd
class_name InventoryData extends Resource

@export_group("Inventário")
@export var armor: Array[ItemArmadura] = [Database.ARMORNULL,Database.OCULOS_SIMPLES, ItemArmadura.new()]
@export var weapons: Array[ItemArma] = [Database.WEAPONNULL, Database.SIGNAL_WEAPON, ItemArma.new()]
@export var itens: Array[DataItem] = [Database.SANDWICH]
@export var itens_battle: Array[DataItem] = []
