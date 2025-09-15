@icon("res://texture/folderTres/save_png.tres")
class_name GlobalData extends Resource

@export var slot: int = 0
@export var name: String = "New Save"
@export var CurrentScene: PackedScene = preload("res://Areais/EP 1/começo.tscn")

@export var AllInventory: Dictionary[String, Inventory] = {"Zeno": preload("res://Godot/classes/itens/Inventorys/ZenoInventory.tres")}
@export var CurrentInventory: String = "Zeno"

@export var AllPlayers: Dictionary[String, PlayerData] = {"Zeno": preload("res://Godot/classes/personagens/zeno.tres")}
@export var PlayersAtuais: Array[String] = ["Zeno"]
@export var CurrentPlayer: String = "Zeno"

@export var Conf: DataConf = DataConf.new()
@export var Extras: DataExtras = DataExtras.new()
