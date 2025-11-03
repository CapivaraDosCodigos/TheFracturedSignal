extends Node2D

@export var makers: Array[Marker2D]
var lastplayer: ObjectPlayer2D = null

func _ready() -> void:
	pass
	spawns()

func spawns() -> void:
	var idx: int = 0
	for key: String in Manager.PlayersAtuais.keys():
		var playerload : PackedScene = load(Manager.PlayersAtuais[key].ObjectPlayerPath)
		var playerins : ObjectPlayer2D = playerload.instantiate()
		playerins.position = makers[idx].position
		add_child(playerins)
		lastplayer = playerins
		playerins.Nome = key
		playerins.leader = lastplayer
		idx += 1
