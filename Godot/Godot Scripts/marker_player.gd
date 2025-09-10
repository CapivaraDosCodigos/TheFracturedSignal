extends Node2D
class_name MarkerPlayer

var markers: Array[Marker2D] = []
var players: Array = []
var current_leader_name: String = ""

func _ready() -> void:
	await get_tree().process_frame
	for child in get_children():
		if child is Marker2D:
			markers.append(child)
	instaciar()

func instaciar() -> void:
	# pega o player atual e o resto do dicionário
	current_leader_name = Starts.Current_player.Nome
	var dir: Dictionary = Starts.Pdir.duplicate()
	var current_data = dir.get(current_leader_name, null)
	dir.erase(current_leader_name)

	players.clear()

	# instancia o Current_player no marker[0]
	if current_data and markers.size() > 0:
		var ins = current_data.objectplayer.instantiate()
		add_sibling(ins)
		ins.global_position = markers[0].global_position
		players.append(ins)

	# instancia os demais
	var i := 1
	for player_data in dir.values():
		if player_data != null and i < markers.size():
			var ins = player_data.objectplayer.instantiate()
			add_sibling(ins)
			ins.global_position = markers[i].global_position
			players.append(ins)
			i += 1
	
	define_leaders(players)

func define_leaders(_players: Array) -> void:
	var previous_player: Node = null
	for p in _players:
		if p == null:
			continue

		if previous_player != null:
			if p.has_method("set_leader"):
				p.set_leader(previous_player)
			elif "leader" in p:
				p.leader = previous_player
		else:
			# primeiro não tem líder
			if p.has_method("set_leader"):
				p.set_leader(null)
			elif "leader" in p:
				p.leader = null
			
		previous_player = p

func _process(_delta: float) -> void:
	# checa se o líder mudou no Starts
	if Starts.Current_player.Nome != current_leader_name:
		# coloca o novo líder na frente do array
		var novo_nome = Starts.Current_player.Nome
		for i in range(players.size()):
			if players[i].Nome == novo_nome: # assumindo que ObjectPlayer tem "Nome"
				var novo_lider = players[i]
				players.remove_at(i)
				players.insert(0, novo_lider)
				break
		current_leader_name = novo_nome
		define_leaders(players)
