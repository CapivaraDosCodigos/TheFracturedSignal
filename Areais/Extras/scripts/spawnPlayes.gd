extends Node2D
class_name SpawnPlayers

@export var makers: Array[Marker2D]

func _ready() -> void:
	var players_data: Array[PlayerData] = Manager.PlayersAtuais.values()
	var players_inst: Array[ObjectPlayer2D] = []
	
	for i: int in players_data.size():
		var data: PlayerData = players_data[i]
		var obj: ObjectPlayer2D = load(data.ObjectPlayerPath).instantiate()
	
		add_child(obj)
		obj.position = makers[i].position
		players_inst.append(obj)
	
		if i < makers.size():
			obj.global_position = makers[i].global_position
	
	#players_inst.reverse()
	var leader := players_inst[0]
	
	for player in players_inst:
		player.leader = leader
