@icon("res://Resources/texturas/globalsave.tres")
class_name SeasonResource extends Resource


@export var nome: String = "Season"

@export_category("Players")
@export var Players: Dictionary[String, PlayerData] = {}
@export_enum("Zeno", "Niko") var PlayersAtuais: Array[String] = []
@export_enum("Zeno", "Niko") var CurrentPlayer: String = "Zeno"

@export_group("Extras")
@export var Extras: DataExtras = DataExtras.new()
@export var TimeSave: String = "00/00/0000 00h00"

@export_group("PackedScenes")
@export_file("*.*tscn") var StartScene: String
@export_file("*.*tscn") var CurrentScene: String

var slot: int = 0

func get_players() -> Dictionary[String, PlayerData]:
	var players: Dictionary[String, PlayerData] = {}
	
	for player in PlayersAtuais:
		if Players.has(player):
			players[player] = Players[player]
			
	return players
