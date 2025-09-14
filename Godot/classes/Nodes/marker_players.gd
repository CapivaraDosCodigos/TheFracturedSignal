extends Node2D
class_name MarkerPlayersNew

var markers: Array[Marker2D] = []
var players: Array = []

func _ready() -> void:
	await get_tree().process_frame
	for child in get_children():
		if child is Marker2D:
			markers.append(child)
	
	instanciar_players()

func instanciar_players() -> void:
	var dir: Dictionary = Starts.Pdir.duplicate()
	if dir.is_empty() or markers.is_empty():
		return
	
	players.clear()
	
	if not (Starts.Current_player.has_method("update_properties")):
		await get_tree().process_frame
	
	var current_name = Starts.Current_player.Nome
	var current_data = dir.get(current_name, null)
	dir.erase(current_name)

	if current_data:
		var inz = load(current_data.objectplayer)
		var ins = inz.instantiate()
		add_sibling(ins)
		ins.global_position = markers[0].global_position
		players.append(ins)

	# 2. Instancia os demais jogadores nos outros markers
	var i := 1
	for player_data in dir.values():
		if player_data != null and i < markers.size():
			var inz = load(player_data.objectplayer)
			var ins = inz.instantiate()
			add_sibling(ins)
			ins.global_position = markers[i].global_position
			players.append(ins)
			i += 1

	# 3. Define líderes
	define_leaders(players)

func define_leaders(_players: Array) -> void:
	var previous: Node = null
	for p in _players:
		if p == null:
			continue
		if previous != null:
			if p.has_method("set_leader"):
				p.set_leader(previous)
			elif "leader" in p:
				p.leader = previous
		else:
			# o primeiro não tem líder
			if p.has_method("set_leader"):
				p.set_leader(null)
			elif "leader" in p:
				p.leader = null
		previous = p
