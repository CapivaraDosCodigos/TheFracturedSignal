class_name BattleEntityManager2D
extends HBoxContainer

@onready var inimigoMarker2D: Array[Control] = [ $HBoxContainer/inimigo_1/NewInimigo1, $HBoxContainer/Control4/NewInimigo2, $HBoxContainer/Control/NewPlayer3 ]
@onready var playerMarker2D: Array[Control] = [ $HBoxContainer/player_1/NewPlayer1, $HBoxContainer/Control/NewPlayer2, $HBoxContainer/Control/NewPlayer3 ]

var enemiesNodes: Dictionary[int, EnemiesBase2D] = {}
var playersNodes: Array[PlayerBase2D] = []

func adicionar_jogador(index: int, key: String, PlayersDIR: Dictionary[String, PlayerData], containers_players: Array[ContainerPlayer]) -> void:
	var inst: PlayerBase2D = load(PlayersDIR[key].PlayerBatalhaPath).instantiate()
	playersNodes.append(inst)
	inst.id = playersNodes.size() - 1
	inst.player = key
	#inst.global_position = playerMarker2D[index].global_position
	
	containers_players[index].player = PlayersDIR.keys().get(index)
	containers_players[index].visible = true
	
	playerMarker2D[index].add_child(inst)

func adicionar_inimigo(inimigo: PackedScene, intex: int) -> void:
	var inst: EnemiesBase2D = inimigo.instantiate()
	var chave: int = intex

	while enemiesNodes.has(chave):
		chave += 1

	inst.id = chave
	#inst.global_position = inimigoMarker2D[intex].global_position

	inimigoMarker2D[intex].add_child(inst)
	enemiesNodes[chave] = inst

func remover_jogador_(key: String, PlayersDIR: Dictionary[String, PlayerData], containers_players: Array[ContainerPlayer]) -> void:
	if not PlayersDIR.has(key):
		return

	for player in playersNodes:
		if player.player == key:
			player.queue_free()
			playersNodes.erase(player)
			break

	for i in range(playersNodes.size()):
		var node: PlayerBase2D = playersNodes[i]
		node.id = i
		#node.global_position = playerMarker2D[i].global_position
		playerMarker2D[i].add_child(node)
	
	for i in range(containers_players.size()):
		if i < playersNodes.size():
			containers_players[i].player = playersNodes[i].player
			containers_players[i].visible = true
		else:
			containers_players[i].player = ""
			containers_players[i].visible = false

func remover_inimigo(id: int) -> bool:
	if not enemiesNodes.has(id):
		return false

	var node: EnemiesBase2D = enemiesNodes[id]
	node.queue_free()
	enemiesNodes.erase(id)

	var novos: Dictionary[int, EnemiesBase2D] = {}
	var index: int = 0

	for enemy: EnemiesBase2D in enemiesNodes.values():
		enemy.id = index
		#enemy.global_position = inimigoMarker2D[index].global_position
		novos[index] = enemy
		index += 1
		
		inimigoMarker2D[index].add_child(enemy)

	enemiesNodes = novos
	
	return enemiesNodes.is_empty()

func atacar():
	if enemiesNodes.is_empty(): return
	
	for enemie: EnemiesBase2D in enemiesNodes.values():
		enemie.atacar()

	var espera: float = enemiesNodes.values().pick_random().time
	await get_tree().create_timer(espera).timeout

	Manager.change_state("BATTLE_MENU")

func verificar_dead() -> bool:
	return playersNodes.all(func(p): return p.fallen)
