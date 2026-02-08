extends Node2D
class_name SpawnPlayers

@export var makers: Array[Marker2D]

func _ready() -> void:
	instantiate_players()

func instantiate_players(players_data: Array[PlayerData] = Manager.PlayersAtuais.values()) -> void:
	var players_inst: Array[ObjectPlayer2D] = []
	
	for i: int in players_data.size():
		var data: PlayerData = players_data[i]
		var obj: ObjectPlayer2D = load(data.ObjectPlayerPath).instantiate()
	
		add_child(obj)
		obj.position = makers[i].position
		players_inst.append(obj)
	
		if i < makers.size():
			obj.global_position = makers[i].global_position

	var leader: ObjectPlayer2D = players_inst[0]
	
	for player in players_inst:
		player.leader = leader
