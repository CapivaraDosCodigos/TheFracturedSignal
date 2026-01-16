@icon("res://Resources/texturas/batalha.tres")
class_name Batalha2D
extends Node2D

#region vars

const MAX_ENENINES: int = 3

@onready var containers_players: Array[ContainerPlayer] = [ %ContainerPlayer1, %ContainerPlayer2, %ContainerPlayer3 ]
@onready var personagens: PersonagensBatalha2D = $BatalhaCanvas/Personagens
@onready var points_progress_bar: TextureProgressBar = %PointsProgressBar
@onready var battle_arena: BattleArenaControl = %BATTLE_ARENA
@onready var anim: AnimationPlayer = $AnimationPanel

var itens_usados_temp: Dictionary[String, DataItem] = {}
var cp_delta_por_jogador: Dictionary[String, int] = {}
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
var concentration_points_visual: float = 0.0
var concentration_points: int = 0
var current_index: int = 0
var shift: int = 0

var selecao_finalizada: bool = false
var selecao_ativa: bool = false
var submenu_ativo: bool = false

#endregion

func _ready() -> void:
	
	while batalha.inimigos.size() > MAX_ENENINES:
		batalha.inimigos.pop_back()

	PlayersDIR = Manager.PlayersAtuais
	player_keys = PlayersDIR.keys()
	player_keys.reverse()

	for idx in player_keys.size():
		adicionar_jogador(idx, player_keys[idx])

	for i in batalha.inimigos.size():
		adicionar_inimigo(batalha.inimigos[i], i)

	await get_tree().create_timer(1.5).timeout
	DialogueManager.show_example_dialogue_balloon(load(batalha.dialogo), batalha.start_dialogo)

	Manager.tocar_musica(batalha.DataAudio, 1)

func _process(delta: float) -> void:
	var state = Manager.CurrentStatus
	if state != last_state:

		if state == Manager.GameState.BATTLE:
			anim.play("S_panel")
			for container in containers_players:
				container.isfocus = false

		elif state == Manager.GameState.BATTLE_MENU:
			anim.play("E_panel")
			_iniciar_selecao()
		
		last_state = state
	
	if last_state == Manager.GameState.BATTLE_MENU and state != Manager.GameState.BATTLE_MENU:
		cp_delta_por_jogador.clear()

	concentration_points_visual = lerp(concentration_points_visual, float(concentration_points), 8.0 * delta)

	points_progress_bar.value = concentration_points_visual
	$BatalhaCanvas/Control/Label.text = str(round(concentration_points_visual))
	
	if verificar_dead():
		dead_batalha()

func _unhandled_input(event: InputEvent) -> void:
	if not selecao_ativa or selecao_finalizada:
		return
	
	var container: ContainerPlayer = _get_container_player(jogador_atual)
	if not container:
		return
	
	if submenu_ativo:
		if event.is_action_pressed("cancel"):
			Manager.tocar_musica(PathsMusic.CANCEL, 3)
			_fechar_submenu()
		return

	if event.is_action_pressed("Right"):
		Manager.tocar_musica(PathsMusic.MODERN_5, 2)
		container.next_button()

	elif event.is_action_pressed("Left"):
		Manager.tocar_musica(PathsMusic.MODERN_5, 2)
		container.previous_button()

	elif event.is_action_pressed("confirm"):
		Manager.tocar_musica(PathsMusic.MODERN_9, 3)
		_abrir_submenu(container.get_current_action_name())
	
	elif event.is_action_pressed("cancel"):
		Manager.tocar_musica(PathsMusic.CANCEL, 3)
		_cancelar_jogador_anterior()

func _iniciar_selecao() -> void:
	selecao_ativa = true
	selecao_finalizada = false
	current_index = 0
	shift += 1
	print(shift)
	
	selecoes.clear()
	submenu_resultados.clear()
	itens_usados_temp.clear()
	cp_delta_por_jogador.clear()
	
	itens_locais = Manager.get_Inventory().get_in_items_batalha().duplicate(true)
	
	for player: PlayerData in PlayersDIR.values():
		player.apply_effects()
		player.isDefesa = false

	jogador_atual = proximo_jogador_valido(0)
	_focus_container_atual()

func _abrir_submenu(act: String) -> void:
	var container: ContainerPlayer = _get_container_player(jogador_atual)
	if not container: return
	
	match act:
		"DEF", "ACT":
			_confirmar_acao(act)
	
		"ATK":
			submenu_ativo = true
			container.inimigos_menu.atualizar_inimigos(enemiesNodes)
			var res: int = await container.inimigos_menu.get_inimigo()
			if res >= 0:
				submenu_resultados[jogador_atual] = res
				_confirmar_acao(act, res)
			container.fechar_submenus()
			submenu_ativo = false
	
		"EXE":
			submenu_ativo = true
			if PlayersDIR[jogador_atual].get_Executables().is_empty():
				container.fechar_submenus()
				submenu_ativo = false
				_focus_container_atual()
				return
			
			container.inimigos_menu.atualizar_inimigos(enemiesNodes)
			container.player_menu.atualizar_players(PlayersDIR.values())
			var result: Dictionary = await container.executable_menu.get_Executable(PlayersDIR[jogador_atual])
			if result["index"] >= 0:
				var exe: Executable = PlayersDIR[jogador_atual].get_Executables().get(result["index"])
				submenu_resultados[jogador_atual] = {
					"exe": exe,
					"Dictionary": { "player": result["player"], "inimigo": result["inimigo"] }
				}
				_confirmar_acao(act)

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
			container.player_menu.atualizar_players(PlayersDIR.values())
			
			var result: Dictionary = await container.itens_menu.itemsIvt()
			if result["index"] >= 0 and result["index"] < itens_locais.size():
				var item: DataItem = itens_locais[result["index"]]
				submenu_resultados[jogador_atual] = {
					"item": item,
					"player": result["player"],
					"index": result["index"]
				}
				itens_usados_temp[jogador_atual] = item
				itens_locais.erase(item)
				container.itens_menu.atualizar_itemlist(itens_locais)
				_confirmar_acao(act)

			container.fechar_submenus()
			submenu_ativo = false
		
		_:
			Manager.tocar_musica(PathsMusic.SCI_FI_ERROR, 2)

func _confirmar_acao(nome: String, _extra = null) -> void:
	if cp_delta_por_jogador.has(jogador_atual):
		_reverter_concentration_temporario(jogador_atual)

	match nome:
		"DEF":
			var ganho: int = min(10, 100 - concentration_points)
			if ganho > 0:
				aplicar_concentration_temporario(jogador_atual, ganho)
				
		"EXE":
			var resut: Dictionary = submenu_resultados[jogador_atual]
			var exe: Executable = resut["exe"]
			exe.coprando()

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

		cp_delta_por_jogador.clear()
		Manager.change_state("BATTLE")
	else:
		_focus_container_atual()

func _cancelar_jogador_anterior() -> void:
	var idx: int = player_keys.find(jogador_atual)
	if idx <= 0 or selecao_finalizada:
		return
	
	var jogador_cancelado: String = player_keys[idx - 1]
	while idx > 0 and deve_pular_jogador(jogador_cancelado):
		idx -= 1
		jogador_cancelado = player_keys[idx]
	
	if submenu_resultados.has(jogador_cancelado):
		var dado = submenu_resultados[jogador_cancelado]
		if typeof(dado) == TYPE_DICTIONARY and dado.has("item"):
			var item: DataItem = dado["item"]
			var index_original: int = dado.get("index", itens_locais.size())
			index_original = clamp(index_original, 0, itens_locais.size())
			itens_locais.insert(index_original, item)
			
		submenu_resultados.erase(jogador_cancelado)
		itens_usados_temp.erase(jogador_cancelado)
		selecoes.erase(jogador_cancelado)
		
	if cp_delta_por_jogador.has(jogador_cancelado):
		_reverter_concentration_temporario(jogador_cancelado)
	jogador_atual = jogador_cancelado
	_focus_container_atual()

func _focus_container_atual() -> void:
	for container in containers_players:
		container.set_focus(false)

	var idx: int = player_keys.find(jogador_atual)
	if idx >= 0 and idx < containers_players.size():
		containers_players[idx].set_focus(true)

func _get_container_player(key: String) -> ContainerPlayer:
	var idx: int = player_keys.find(key)

	if idx >= 0 and idx < containers_players.size():
		return containers_players[idx]

	return null

func _fechar_submenu() -> void:
	submenu_ativo = false
	var cont: ContainerPlayer = _get_container_player(jogador_atual)
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
			inimigo.apply_damage(PlayersDIR[key].maxdamage)
			#print(PlayersDIR[key].maxdamage)

		await get_tree().process_frame
		if enemiesNodes.is_empty():
			return

	elif act == "DEF":
		PlayersDIR[key].isDefesa = true
	
	elif act == "EXE":
		var resut: Dictionary = submenu_resultados[key]
		var exe: Executable = resut["exe"]
		exe.executar(submenu_resultados[key].get("Dictionary"))
	
	elif act == "ITM":
		if not submenu_resultados.has(key):
			return
	
		var item_usado: DataItem = submenu_resultados[key].get("item")
		if item_usado == null:
			return
	
		item_usado.usar(submenu_resultados[key].get("player"))
	
		Manager.get_Inventory().remove_for_item(item_usado)
		var container :ContainerPlayer = _get_container_player(key)
		if container:
			container.itens_menu.atualizar_itemlist()
	
	elif act == "ACT":
		pass

func _reverter_concentration_temporario(jogador: String) -> void:
	if not cp_delta_por_jogador.has(jogador):
		return
	
	concentration_points = clamp(
		concentration_points - cp_delta_por_jogador[jogador],
		0,
		100
	)
	
	cp_delta_por_jogador.erase(jogador)

func aplicar_concentration_temporario(jogador: String, valor: int) -> void:
	concentration_points = clamp(concentration_points + valor, 0, 100)
	cp_delta_por_jogador[jogador] = cp_delta_por_jogador.get(jogador, 0) + valor

func proximo_jogador_valido(inicio: int) -> String:
	for i in range(inicio, player_keys.size()):
		var key: String = player_keys[i]

		if not PlayersDIR.has(key):
			continue

		var p: PlayerData = PlayersDIR[key]

		if p.fallen:
			continue

		if p.skip_turn:
			continue

		return key

	return ""

func deve_pular_jogador(key: String) -> bool:
	var player = PlayersDIR.get(key, null)
	return not player or player.fallen or player.skip_turn

func verificar_dead() -> bool:
	return playersNodes.all(func(p): return p.fallen)

func end_batalha(enemie: bool = true) -> void:
	if enemiesNodes.size() > 0 and enemie: return
	#await get_tree().create_timer(2.0).timeout
	Manager.tocar_musica(DataAudioPlayer.new())
	set_process(false)
	batalha.dungeons2D.end_batalha.emit()
	Manager.Extras.EnemiesVistos.append(batalha.id)
	Manager.CurrentBatalha = null
	queue_free()

func dead_batalha() -> void:
	await get_tree().create_timer(0.0).timeout
	Manager.tocar_musica(DataAudioPlayer.new())
	set_process(false)
	Manager.Game_Over()
	Manager.Extras.EnemiesVistos.append(batalha.id)
	Manager.CurrentBatalha = null
	queue_free()

func add_concentration_points(value: int) -> void:
	concentration_points = clamp(concentration_points + value, 0.0, 100.0)

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
   
