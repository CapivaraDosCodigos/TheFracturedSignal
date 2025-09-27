#@icon("res://texture/folderTres/texturas/globalsave.tres")
class_name SeasonResource extends Resource

@export_range(0, 5) var slot: int = 0

@export var name: String = "Season"

@export var StartScene: PackedScene

@export var CurrentScene: PackedScene

@export var CurrentInventory: Inventory

@export var PlayersAtuais: Dictionary[String, PlayerData]

@export_enum("Zeno", "Niko") var CurrentPlayer: String

@export var Extras: DataExtras

@export var TimeSave: String = "00-00-00"
