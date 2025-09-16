@icon("res://texture/folderTres/save_png.tres")
class_name GlobalData extends Resource

@export var slot: int = 0
@export var name: String = "New Save"
@export var CurrentScene: PackedScene

@export var AllInventory: Dictionary[String, Inventory]
@export_enum("Zeno", "Niko") var CurrentInventory: String

@export var AllPlayers: Dictionary[String, PlayerData]
@export var PlayersAtuais: Array[String]
@export_enum("Zeno", "Niko") var CurrentPlayer: String

@export var Conf: DataConf
@export var Extras: DataExtras
