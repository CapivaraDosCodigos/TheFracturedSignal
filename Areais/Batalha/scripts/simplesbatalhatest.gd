@icon("res://texture/folderTres/texturas/batalha.tres")
extends Node2D

#region variables

const MAX_ENENINES: int = 3

@onready var panel_dict: Dictionary[String, Control] = { "ATK": %ATK, "ITM": %ITM, "EXE": %EXE, "DEF": %DEF, "MRC": %MRC } #nao vou usar mais isso
@onready var containers_players: Array[VContainerPlayerSimples] = [ %VContainerPlayer1, %VContainerPlayer2, %VContainerPlayer3, %VContainerPlayer4, %VContainerPlayer5 ]
@onready var inimigosMenu: batalha_submenu_enemies = $BatalhaCanvas/Control/ControlBASE/inimigos
@onready var itemMenu: batalha_submenu_itens = $BatalhaCanvas/Control/ControlBASE/itens
@onready var panels: Array[Control] = [ %ATK, %ITM, %EXE, %DEF, %MRC ] #nao vou usar mais isso
@onready var personagens: PersonagensBatalha2D = $BatalhaCanvas/Personagens
@onready var battle_arena: NinePatchRect = %BATTLE_ARENA
@onready var anim: AnimationPlayer = $AnimationPanel

var playersNodes: Array[PlayerBase2D] = []
var itens_locais: Array[DataItem] = []
var player_keys: Array[String] = []

var itens_usados_temp: Dictionary[String, DataItem] = {}
var enemiesNodes: Dictionary[int, EnemiesBase2D] = {}
var PlayersDIR: Dictionary[String, PlayerData] = {}
var selecoes: Dictionary[String, String] = {}
var submenu_resultados: Dictionary = {}

var batalha: DataBatalha = null
var last_state = null

var jogador_atual: String = ""

var current_index: int = 0
var players: int = 0

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
	
	if submenu_ativo:
		if event.is_action_pressed("cancel"):
			_fechar_submenu()
		return
	
	if event.is_action_pressed("Right"):
		current_index = min(current_index + 1, panels.size() - 1)
		_focus_current_panel()
		
	elif event.is_action_pressed("Left"):
		current_index = max(current_index - 1, 0)
		_focus_current_panel()
		
	elif event.is_action_pressed("confirm"):
		_abrir_submenu(panels[current_index])
		
	elif event.is_action_pressed("cancel"):
		var idx = player_keys.find(jogador_atual)
		if idx > 0 and not selecao_finalizada:
			var jogador_cancelado = player_keys[idx - 1]

			if itens_usados_temp.has(jogador_cancelado):
				var item_cancelado: DataItem = itens_usados_temp[jogador_cancelado]
				itens_locais.append(item_cancelado)
				itens_usados_temp.erase(jogador_cancelado)
				itemMenu.atualizar_itemlist(itens_locais)
	
			if submenu_resultados.has(jogador_cancelado):
				submenu_resultados.erase(jogador_cancelado)
				
			if selecoes.has(jogador_cancelado):
				selecoes.erase(jogador_cancelado)
	
			jogador_atual = jogador_cancelado
			var acao = selecoes.get(jogador_atual, "")
			current_index = panels.find(panel_dict.get(acao, panels[0]))
			_focus_current_panel()

func _iniciar_selecao():
	await get_tree().create_timer(0.5).timeout
	selecao_ativa = true
	selecao_finalizada = false
	current_index = 0
	selecoes.clear()
	submenu_resultados.clear()
	itens_usados_temp.clear()

	for i in Manager.PlayersAtuais.keys():
		Manager.PlayersAtuais[i].isDefesa = false

	itens_locais = Manager.CurrentInventory.get_in_items_batalha().duplicate(true)
	itemMenu.atualizar_itemlist(itens_locais)
	jogador_atual = _proximo_jogador_valido(0)
	_focus_current_panel()

func _abrir_submenu(panel: Control) -> void:
	current_index = 0
	for nome in panel_dict:
		if panel_dict[nome] == panel:
			match nome:
				"DEF", "EXE", "MRC":
					_confirmar_acao(nome)
				"ATK":
					submenu_ativo = true
					var resultado = await inimigosMenu.get_inimigo(enemiesNodes)
					if resultado < 0:
						_focus_current_panel()
						_fechar_submenu()
						return
	
					submenu_resultados[jogador_atual] = resultado
					_confirmar_acao(nome, resultado)
					_fechar_submenu()
				"ITM":
					submenu_ativo = true
	
					if itens_locais.is_empty():
						_focus_current_panel()
						_fechar_submenu()
						return
	
					itemMenu.atualizar_itemlist(itens_locais)
					var resultado = await itemMenu.itemsIvt()
	
					if resultado < 0 or resultado >= itens_locais.size():
						_focus_current_panel()
						_fechar_submenu()
						return
	
					var item_escolhido: DataItem = itens_locais[resultado]
					submenu_resultados[jogador_atual] = item_escolhido
					itens_usados_temp[jogador_atual] = item_escolhido
	
					itens_locais.erase(item_escolhido)
					itemMenu.atualizar_itemlist(itens_locais)
	
					_confirmar_acao(nome)
					_fechar_submenu()

func _confirmar_acao(nome: String, _dados_extra = null) -> void:
	selecoes[jogador_atual] = nome
	var idx = player_keys.find(jogador_atual)
	
	var proximo_idx = idx + 1
	jogador_atual = _proximo_jogador_valido(proximo_idx)

	if jogador_atual != "":
		current_index = 0
		_focus_current_panel()
	else:
		selecao_ativa = false
		selecao_finalizada = true
		
		for key in player_keys:
			_act(selecoes.get(key, ""), key)
			
		Manager.change_state(Manager.GameState.BATTLE)

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

func _focus_current_panel() -> void:
	if selecao_ativa and panels[current_index]:
		await get_tree().process_frame
		panels[current_index].grab_focus()

func _fechar_submenu() -> void:
	submenu_ativo = false
	itemMenu.end()
	_focus_current_panel()

func _exe_atacar():
	if enemiesNodes.is_empty():
		return
	for i in enemiesNodes.keys():
		enemiesNodes[i].atacar()
		
	await get_tree().create_timer(enemiesNodes.values().pick_random().time).timeout
	Manager.change_state(Manager.GameState.BATTLE_MENU)

func _verificar_dead() -> bool:
	return playersNodes.all(func(p): return p.fallen)

func _proximo_jogador_valido(inicio: int) -> String:
	for i in range(inicio, player_keys.size()):
		var key = player_keys[i]
		var player_data: PlayerData = Manager.PlayersAtuais[key]
		
		if not player_data.fallen and not player_data.skip_turn:
			return key
	
	return ""

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
	#playerinst.rootbatalha = self
	playerinst.player = key
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
	#inim.rootbatalha = self
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
