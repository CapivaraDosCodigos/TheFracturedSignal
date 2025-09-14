#Inventory.gd
@icon("res://texture/folderTres/texturas/inventory_png.tres")
class_name Inventory extends Resource

@export var armor: Array[ItemArmadura] = [Database.ARMORNULL,Database.OCULOS_SIMPLES, ItemArmadura.new()]
@export var weapons: Array[ItemArma] = [Database.WEAPONNULL, Database.SIGNAL_WEAPON, ItemArma.new()]
@export var itens: Array[DataItem] = [Database.SANDWICH]
@export var itens_battle: Array[DataItem] = []
