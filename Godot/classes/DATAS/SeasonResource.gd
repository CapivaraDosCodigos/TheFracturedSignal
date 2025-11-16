#@icon("res://texture/folderTres/texturas/globalsave.tres")
class_name SeasonResource extends Resource

@export_range(0, 5) var slot: int = 0

@export var nome: String = "Season"

@export var StartScene: PackedScene

@export var CurrentScene: PackedScene

@export var PlayersAtuais: Dictionary[String, PlayerData]

@export_enum("Zeno", "Niko") var CurrentPlayer: String

@export var Extras: DataExtras

@export var TimeSave: String = "00/00/0000 00h00"

#func _init(_slot: int = 0, _nome: String = "Season", _StartScene: PackedScene = null, _CurrentScene: PackedScene = null, _PlayersAtuais: Dictionary[String, PlayerData] = {}, _CurrentPlayer: String = "", _Extras: DataExtras = DataExtras.new(), _TimeSave: String = "00/00/0000 00h00") -> void:
	#slot = _slot
	#nome = _nome
	#StartScene = _StartScene
	#CurrentScene = _CurrentScene
	#PlayersAtuais = _PlayersAtuais
	#CurrentPlayer = _CurrentPlayer
	#Extras = _Extras
	#TimeSave = _TimeSave
