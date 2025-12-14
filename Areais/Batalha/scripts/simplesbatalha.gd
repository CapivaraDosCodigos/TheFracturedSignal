@icon("res://texture/folderTres/texturas/batalha.tres")
class_name SimplesBatalha2D
extends Node2D


#region vars

const MAX_ENENINES: int = 3

@onready var containers_players: Array[ContainerPlayerSimples] = [ %ContainerPlayer1, %ContainerPlayer2, %ContainerPlayer3 ]

@onready var personagens: PersonagensBatalha2D = $BatalhaCanvas/Personagens
@onready var points_progress_bar: TextureProgressBar = %PointsProgressBar
@onready var battle_arena: NinePatchRect = %BATTLE_ARENA
@onready var anim: AnimationPlayer = $AnimationPanel

var itens_usados_temp: Dictionary[String, DataItem] = {}
var enemiesNodes: Dictionary[int, EnemiesBase2D] = {}
var PlayersDIR: Dictionary[String, PlayerData] = {}
var selecoes: Dictionary[String, String] = {}
var submenu_resultados: Dictionary = {}

var playersNodes: Array[PlayerBase2D] = []
var itens_locais: Array[DataItem] = []
var player_keys: Array[String] = []

var batalha: DataBatalha = null
var last_state = null

var jogador_atual: String = ""
var current_index: int = 0
var players: int = 0

var selecao_finalizada: bool = false
var selecao_ativa: bool = false
var submenu_ativo: bool = false

#endregion

var concentration_points: int = 0

func _ready() -> void:
	while batalha.inimigos.size() > MAX_ENENINES:
		batalha.inimigos.pop_back()

	PlayersDIR = Manager.PlayersAtuais
	player_keys = PlayersDIR.keys()
	player_keys.reverse()
	players = player_keys.size()

	for idx in players:
		adicionar_jogador(idx, player_keys[idx])

	for i in batalha.inimigos.size():
		adicionar_inimigo(batalha.inimigos[i], i)

	await get_tree().create_timer(1.5).timeout
	DialogueManager.show_example_dialogue_balloon(load(batalha.dialogo), batalha.start_dialogo)

	Manager.tocar_musica(batalha.caminho, batalha.volume, batalha.loop, 0.0, 1)

func _process(_delta: float) -> void:
	var state = Manager.current_status
	if state != last_state:

		if state == Manager.GameState.BATTLE:
			anim.play("S_panel")
			for container in containers_players:
				container.isfocus = false

		elif state == Manager.GameState.BATTLE_MENU:
			anim.play("E_panel")
			_iniciar_selecao()

		last_state = state
	
	points_progress_bar.value = concentration_points
	if verificar_dead():
		dead_batalha()

func _unhandled_input(event: InputEvent) -> void:
	if not selecao_ativa or selecao_finalizada:
		return
	
	var container: ContainerPlayerSimples = _get_container_do_jogador(jogador_atual)
	if not container:
		return
	
	if submenu_ativo:
		if event.is_action_pressed("cancel"):
			_fechar_submenu()
		return

	if event.is_action_pressed("Right"):
		container.next_button()

	elif event.is_action_pressed("Left"):
		container.previous_button()

	elif event.is_action_pressed("confirm"):
		_abrir_submenu(container.get_current_action_name())

	elif event.is_action_pressed("cancel"):
		_cancelar_jogador_anterior()

func _iniciar_selecao() -> void:
	selecao_ativa = true
	selecao_finalizada = false
	current_index = 0
	
	selecoes.clear()
	submenu_resultados.clear()
	itens_usados_temp.clear()
	
	itens_locais = Manager.get_Inventory().get_in_items_batalha().duplicate(true)

	for p in Manager.PlayersAtuais.values():
		p.isDefesa = false

	jogador_atual = proximo_jogador_valido(0)
	_focus_container_atual()

func _abrir_submenu(act: String) -> void:
	var container: ContainerPlayerSimples = _get_container_do_jogador(jogador_atual)
	if not container: return
	
	match act:
	
		"DEF", "EXE", "MRC":
			_confirmar_acao(act)
	
		"ATK":
			submenu_ativo = true
			var res: int = await container.inimigos_menu.get_inimigo(enemiesNodes)
			if res >= 0:
				submenu_resultados[jogador_atual] = res
				_confirmar_acao(act, res)
			container.fechar_submenus()
			submenu_ativo = false
	
		"ITM":
			submenu_ativo = true
			if itens_locais.is_empty():
				container.fechar_submenus()
				submenu_ativo = false
				_focus_container_atual()
				return
	
			container.itens_menu.atualizar_itemlist(itens_locais)
			var result: int = await container.itens_menu.itemsIvt()
	
			if result >= 0 and result < itens_locais.size():
				var item: DataItem = itens_locais[result]
				submenu_resultados[jogador_atual] = item
				itens_usados_temp[jogador_atual] = item
				itens_locais.erase(item)
				container.itens_menu.atualizar_itemlist(itens_locais)
				_confirmar_acao(act)
	
			container.fechar_submenus()
			submenu_ativo = false

func _confirmar_acao(nome: String, _extra = null) -> void:
	selecoes[jogador_atual] = nome

	var idx: int = player_keys.find(jogador_atual)
	var prox: String = proximo_jogador_valido(idx + 1)
	
	while prox != "" and deve_pular_jogador(prox):
		prox = proximo_jogador_valido(player_keys.find(prox) + 1)
	
	jogador_atual = prox
	
	if jogador_atual == "":
		selecao_finalizada = true
		selecao_ativa = false
	
		for key in player_keys:
			_act(selecoes.get(key, ""), key)

		if enemiesNodes.is_empty():
			return

		Manager.change_state("BATTLE")
	else:
		_focus_container_atual()

func _cancelar_jogador_anterior() -> void:
	var idx: int = player_keys.find(jogador_atual)
	if idx <= 0 or selecao_finalizada:
		return
	
	var ant: String = player_keys[idx - 1]
	
	while idx > 0 and deve_pular_jogador(ant):
		idx -= 1
		ant = player_keys[idx]
	
	jogador_atual = ant
	_focus_container_atual()

func _focus_container_atual() -> void:
	for container in containers_players:
		container.set_focus(false)

	var idx: int = player_keys.find(jogador_atual)
	if idx >= 0 and idx < containers_players.size():
		containers_players[idx].set_focus(true)

func _get_container_do_jogador(key: String) -> ContainerPlayerSimples:
	var idx: int = player_keys.find(key)

	if idx >= 0 and idx < containers_players.size():
		return containers_players[idx]

	return null

func _fechar_submenu() -> void:
	submenu_ativo = false
	var cont: ContainerPlayerSimples = _get_container_do_jogador(jogador_atual)
	if cont:
		cont.fechar_submenus()
	_focus_container_atual()

func _exe_atacar():
	if enemiesNodes.is_empty(): return

	for enemie in enemiesNodes.values():
		enemie.atacar()

	var espera: float = enemiesNodes.values().pick_random().time
	await get_tree().create_timer(espera).timeout

	Manager.change_state("BATTLE_MENU")

func _act(act: String, key: String) -> void:
	if act == "ATK":
		if not submenu_resultados.has(key):
			return
			
		var inimigo_id = submenu_resultados[key]
		var inimigo = enemiesNodes.get(inimigo_id, null)
		
		if inimigo != null:
			inimigo.apply_damage(Manager.PlayersAtuais[key].maxdamage)

		await get_tree().process_frame
		if enemiesNodes.is_empty():
			return

	elif act == "DEF":
		Manager.PlayersAtuais[key].isDefesa = true
	
	elif act == "EXE":
		pass
	
	elif act == "ITM":
		if not submenu_resultados.has(key):
			return
	
		var item_usado: DataItem = submenu_resultados[key]
		if item_usado == null:
			return
	
		for pkey in Manager.PlayersAtuais.keys():
			if item_usado.has_method("usar"):
				item_usado.usar(pkey)
	
		Manager.get_Inventory().remove_for_item(item_usado)
		var container := _get_container_do_jogador(key)
		if container:
			container.itens_menu.atualizar_itemlist()
	
	elif act == "MRC":
			end_batalha(false)

func proximo_jogador_valido(inicio: int) -> String:
	for i in range(inicio, player_keys.size()):
		var key := player_keys[i]

		if not Manager.PlayersAtuais.has(key):
			continue

		var p: PlayerData = Manager.PlayersAtuais[key]

		if p.fallen:
			continue

		if p.skip_turn:
			continue

		return key

	return ""

func deve_pular_jogador(key: String) -> bool:
	var player = Manager.PlayersAtuais.get(key, null)
	return not player or player.fallen or player.skip_turn

func verificar_dead() -> bool:
	return playersNodes.all(func(p): return p.fallen)

func end_batalha(enemie: bool = true) -> void:
	if enemiesNodes.size() > 0 and enemie: return
	await get_tree().create_timer(2.0).timeout
	Manager.tocar_musica()
	set_process(false)
	batalha.dungeons2D.end_batalha.emit()
	queue_free()

func dead_batalha() -> void:
	await get_tree().create_timer(0.0).timeout
	Manager.tocar_musica()
	set_process(false)
	Manager.Game_Over()
	queue_free()

func add_cp(value: int) -> void:
	if concentration_points + value < 100:
		concentration_points += value
	else:
		concentration_points = 100

func adicionar_jogador(index: int, key: String) -> void:
	var inst: PlayerBase2D = load(PlayersDIR[key].PlayerBatalhaPath).instantiate()
	playersNodes.append(inst)
	inst.id = playersNodes.size() - 1
	inst.player = key
	inst.rootbatalha = self
	inst.position = personagens.playerMarker2D[index].position

	containers_players[index].player = key
	containers_players[index].visible = true

	personagens.add_child(inst)

func adicionar_inimigo(inimigo: PackedScene, intex: int) -> void:
	var inst: EnemiesBase2D = inimigo.instantiate()
	var chave: int = intex

	while enemiesNodes.has(chave):
		chave += 1

	inst.id = chave
	inst.rootbatalha = self
	inst.rootobjeto = battle_arena.objetos
	inst.position = personagens.inimigoMarker2D[intex].position

	personagens.add_child(inst)
	enemiesNodes[chave] = inst

	inst.play("default")

func remover_jogador_(key: String) -> void:
	if not PlayersDIR.has(key):
		return

	PlayersDIR.erase(key)

	var idx : int = player_keys.find(key)
	if idx != -1:
		player_keys.remove_at(idx)

	for player in playersNodes:
		if player.player == key:
			player.queue_free()
			playersNodes.erase(player)
			break

	for i in range(playersNodes.size()):
		var node: PlayerBase2D = playersNodes[i]
		node.id = i
		node.position = personagens.playerMarker2D[i].position

	for i in range(containers_players.size()):
		if i < playersNodes.size():
			containers_players[i].player = playersNodes[i].player
			containers_players[i].visible = true
		else:
			containers_players[i].player = ""
			containers_players[i].visible = false
			containers_players[i].reset()

	players = player_keys.size()

	if jogador_atual == key:
		jogador_atual = proximo_jogador_valido(0)
		_focus_container_atual()

func remover_inimigo(id: int) -> void:
	if not enemiesNodes.has(id):
		return

	var node: EnemiesBase2D = enemiesNodes[id]
	node.queue_free()
	enemiesNodes.erase(id)

	var novos: Dictionary[int, EnemiesBase2D] = {}
	var index: int = 0

	for enemy in enemiesNodes.values():
		enemy.id = index
		enemy.position = personagens.inimigoMarker2D[index].position
		novos[index] = enemy
		index += 1

	enemiesNodes = novos

	if enemiesNodes.is_empty():
		end_batalha()
