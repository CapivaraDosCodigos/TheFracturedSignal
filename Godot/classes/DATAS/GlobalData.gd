@icon("res://texture/folderTres/save_png.tres")
class_name GlobalData extends Resource

@export var id: int = 0

@export var name: String = "New Save"

@export var Inv: Inventory = preload("res://Godot/classes/itens/Inventorys/ZenoInventory.tres")

@export var CharDir: Dictionary[String, PlayerData] = {"Zeno": preload("res://Godot/classes/personagens/zeno.tres")}

@export var current_player: PlayerData = preload("res://Godot/classes/personagens/zeno.tres")

@export var Conf: DataConf = DataConf.new()

@export var DataE: DataExtras = DataExtras.new()
