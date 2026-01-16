@icon("res://Resources/texturas/globalsave.tres")
class_name SeasonResource extends Resource


@export var nome: String = "Season"

@export_file("*.*tscn") var StartScene: String

@export_file("*.*tscn") var CurrentScene: String

@export var PlayersAtuais: Dictionary[String, PlayerData]

@export_enum("Zeno", "Niko") var CurrentPlayer: String

@export var Extras: DataExtras

@export var TimeSave: String = "00/00/0000 00h00"

var slot: int = 0
