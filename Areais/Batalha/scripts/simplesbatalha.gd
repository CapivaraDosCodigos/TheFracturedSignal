@icon("res://texture/folderTres/texturas/batalha.tres")
class_name SimplesBatalha2D
extends Node2D

#region variables

const MAX_ENENINES: int = 3

@onready var containers_players: Array[VContainerPlayerSimples] = [
	%VContainerPlayer1, %VContainerPlayer2, %VContainerPlayer3, %VContainerPlayer4, %VContainerPlayer5 ]
@onready var inimigosMenu: batalha_submenu_enemies = $BatalhaCanvas/Control/ControlBASE/inimigos
@onready var itemMenu: batalha_submenu_itens = $BatalhaCanvas/Control/ControlBASE/itens
@onready var personagens: PersonagensBatalha2D = $BatalhaCanvas/Personagens
@onready var battle_arena: NinePatchRect = %BATTLE_ARENA
@onready var anim: AnimationPlayer = $AnimationPanel

var playersNodes: Array[PlayerBase2D] = []
var enemiesNodes: Dictionary[int, EnemiesBase2D] = {}
var PlayersDIR: Dictionary[String, PlayerData] = {}
var player_keys: Array[String] = []

var selecoes: Dictionary[String, String] = {}
var submenu_resultados: Dictionary = {}
var itens_usados_temp: Dictionary[String, DataItem] = {}
var itens_locais: Array[DataItem] = []

var batalha: DataBatalha = null
var last_state = null
var jogador_atual: String = ""
var players: int = 0
var current_index: int = 0
var selecao_finalizada: bool = false
var selecao_ativa: bool = false
var submenu_ativo: bool = false

#endregion

func _ready() -> void:
	while batalha.inimigos.size() > MAX_ENENINES:
		batalha.inimigos.pop_back()
	
	PlayersDIR = Manager.PlayersAtuais
	player_keys = PlayersDIR.keys()
	players = player_keys.size()

	for idx in range(players):
		adicionar_jogador(idx, player_keys[idx])
	
	for i in range(batalha.inimigos.size()):
		adicionar_inimigo(batalha.inimigos[i], i)
	
	await get_tree().create_timer(1.5).timeout
	DialogueManager.show_example_dialogue_balloon(load(batalha.dialogo), batalha.start_dialogo)
	Manager.tocar_musica(batalha.caminho, batalha.volume, batalha.loop)

func _process(_delta: float) -> void:
	var current_state = Manager.current_status
	if current_state != last_state:
		if current_state == Manager.GameState.BATTLE:
			anim.play("S_panel")
			_exe_atacar()
		elif current_state == Manager.GameState.BATTLE_MENU:
			anim.play("E_panel")
			_iniciar_selecao()
		last_state = current_state
		
	if _verificar_dead():
		dead_batalha()

func _unhandled_input(event: InputEvent) -> void:
	if not selecao_ativa or selecao_finalizada:
		return
	
	var container_atual := _get_container_do_jogador(jogador_atual)
	if not container_atual:
		return
	
	if submenu_ativo:
		if event.is_action_pressed("cancel"):
			_fechar_submenu()
		return
	
	if event.is_action_pressed("Right"):
		container_atual.next_button()
		
	elif event.is_action_pressed("Left"):
		container_atual.previous_button()
		
	elif event.is_action_pressed("confirm"):
		_abrir_submenu(container_atual.get_current_action_name())
		
	elif event.is_action_pressed("cancel"):
		_cancelar_jogador_anterior()

func _iniciar_selecao():
	selecao_ativa = true
	selecao_finalizada = false
	current_index = 0
	selecoes.clear()
	submenu_resultados.clear()
	itens_usados_temp.clear()
	itens_locais = Manager.CurrentInventory.get_in_items_batalha().duplicate(true)
	itemMenu.atualizar_itemlist(itens_locais)
	
	for i in Manager.PlayersAtuais.keys():
		Manager.PlayersAtuais[i].isDefesa = false
	
	jogador_atual = _proximo_jogador_valido(0)
	_focus_container_atual()

func _abrir_submenu(act: String) -> void:
	match act:
		"DEF", "EXE", "MRC":
			_confirmar_acao(act)
		"ATK":
			submenu_ativo = true
			var resultado = await inimigosMenu.get_inimigo(enemiesNodes)
			if resultado < 0:
				_focus_container_atual()
				_fechar_submenu()
				return
			submenu_resultados[jogador_atual] = resultado
			_confirmar_acao(act, resultado)
			_fechar_submenu()
		"ITM":
			submenu_ativo = true
			if itens_locais.is_empty():
				_focus_container_atual()
				_fechar_submenu()
				return
			itemMenu.atualizar_itemlist(itens_locais)
			var resultado = await itemMenu.itemsIvt()
			if resultado < 0 or resultado >= itens_locais.size():
				_focus_container_atual()
				_fechar_submenu()
				return
			var item_escolhido: DataItem = itens_locais[resultado]
			submenu_resultados[jogador_atual] = item_escolhido
			itens_usados_temp[jogador_atual] = item_escolhido
			itens_locais.erase(item_escolhido)
			itemMenu.atualizar_itemlist(itens_locais)
			_confirmar_acao(act)
			_fechar_submenu()

func _confirmar_acao(nome: String, _dados_extra = null) -> void:
	selecoes[jogador_atual] = nome
	var idx = player_keys.find(jogador_atual)

	# 🟢 pula automaticamente jogadores mortos ou com skip_turn
	var proximo = _proximo_jogador_valido(idx + 1)
	while proximo != "" and _deve_pular_jogador(proximo):
		proximo = _proximo_jogador_valido(player_keys.find(proximo) + 1)

	jogador_atual = proximo

	if jogador_atual != "":
		_focus_container_atual()
	else:
		selecao_ativa = false
		selecao_finalizada = true
		for key in player_keys:
			_act(selecoes.get(key, ""), key)
		Manager.change_state(Manager.GameState.BATTLE)

func _cancelar_jogador_anterior() -> void:
	var idx = player_keys.find(jogador_atual)
	if idx > 0 and not selecao_finalizada:
		var anterior = player_keys[idx - 1]

		# 🟢 volta até achar um jogador válido
		while idx > 0 and _deve_pular_jogador(anterior):
			idx -= 1
			anterior = player_keys[idx]

		jogador_atual = anterior
		_focus_container_atual()

func _proximo_jogador_valido(inicio: int) -> String:
	for i in range(inicio, player_keys.size()):
		var key = player_keys[i]
		var p: PlayerData = Manager.PlayersAtuais[key]
		if not p.fallen:
			return key
	return ""

func _deve_pular_jogador(key: String) -> bool:
	if not Manager.PlayersAtuais.has(key):
		return true
	var p: PlayerData = Manager.PlayersAtuais[key]
	return p.fallen or p.skip_turn

func _focus_container_atual() -> void:
	for c in containers_players:
		c.set_focus(false)
	var idx = player_keys.find(jogador_atual)
	if idx >= 0 and idx < containers_players.size():
		containers_players[idx].set_focus(true)

func _get_container_do_jogador(key: String) -> VContainerPlayerSimples:
	var idx = player_keys.find(key)
	if idx >= 0 and idx < containers_players.size():
		return containers_players[idx]
	return null

func _fechar_submenu() -> void:
	submenu_ativo = false
	itemMenu.end()
	inimigosMenu.end()
	_focus_container_atual()

func _exe_atacar():
	if enemiesNodes.is_empty():
		return
	for i in enemiesNodes.keys():
		enemiesNodes[i].atacar()
		
	await get_tree().create_timer(enemiesNodes.values().pick_random().time).timeout
	Manager.change_state(Manager.GameState.BATTLE_MENU)

func _verificar_dead() -> bool:
	return playersNodes.all(func(p): return p.fallen)

func _act(act: String, key: String) -> void:
	if act == "ATK":
		if not submenu_resultados.has(key):
			return
			
		var resultado = submenu_resultados[key]
		enemiesNodes[resultado].apply_damage(Manager.PlayersAtuais[key].maxdamage)
	
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
	
		for player in Manager.PlayersAtuais.keys():
			if item_usado.has_method("usar"):
				item_usado.usar(player)
	
		Manager.CurrentInventory.remove_for_item(item_usado)
		itemMenu.atualizar_itemlist()
	
	elif act == "MRC":
		pass
	
	else:
		printerr("erro")

func end_batalha() -> void:
	if enemiesNodes.size() > 0:
		return
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

func adicionar_jogador(index: int, key: String) -> void:
	var playerload = load(PlayersDIR[key].PlayerBatalhaPath)
	var playerinst: PlayerBase2D = playerload.instantiate()
	playersNodes.append(playerinst)
	playerinst.id = playersNodes.size() - 1
	playerinst.player = key
	playerinst.rootbatalha = self
	playerinst.position = personagens.playerMarker2D[index].position
	containers_players[index].player = key
	containers_players[index].visible = true
	personagens.spritesP[index].position.x = playerinst.size_marker
	personagens.add_child(playerinst)

func adicionar_inimigo(inimigo: PackedScene, intex: int) -> void:
	var inim: EnemiesBase2D = inimigo.instantiate()
	var chave: int = intex
	while enemiesNodes.has(chave):
		chave += 1
	inim.id = chave
	inim.rootbatalha = self
	inim.rootobjeto = battle_arena.objetos
	inim.position = personagens.inimigoMarker2D[intex].position
	personagens.add_child(inim)
	enemiesNodes[chave] = inim
	inim.play("default")

func remover_jogador(_key: String) -> void:
	players -= 1

func remover_inimigo(index: int) -> void:
	if enemiesNodes.has(index):
		enemiesNodes.erase(index)
