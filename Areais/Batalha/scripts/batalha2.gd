@icon("res://texture/folderTres/texturas/batalha.tres")
class_name Batalha2D extends Node2D

#region variables

@export var anim: AnimationPlayer
@export var personagens: PersonagensBatalha2D
@export var itemMenu: MarginContainer

@onready var ATK: Control = %panel1
@onready var ITM: Control = %panel2
@onready var EXE: Control = %panel3
@onready var DEF: Control = %panel4
@onready var MRC: Control = %panel5
@onready var battle_arena: NinePatchRect = %BATTLE_ARENA
@onready var paneis_players: Array[PanelPlayer] = [ %PanelPlayer1, %PanelPlayer2, %PanelPlayer3, %PanelPlayer4 ]

const MAX_ENENINES: int = 3

var last_state = null
var submenu_resultados: Dictionary
var PlayersDIR: Dictionary[String, PlayerData]
var panel_dict: Dictionary[String, Control]
var batalha: DataBatalha
var panels: Array[Control]
var selecoes: Dictionary[String, String] = {}

var enemiesNodes: Array[EnemiesBase2D] = []
var playersNodes: Array[PlayerBase2D] = []

var players: int = 1
var current_index: int = 0
var jogador_atual: String = ""
var player_keys: Array[String] = []

var selecao_ativa: bool = false
var selecao_finalizada: bool = false
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
	
	panels = [ATK, ITM, EXE, DEF, MRC]
	panel_dict = {"ATK": ATK, "ITM": ITM, "EXE": EXE, "DEF": DEF, "MRC": MRC}

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
			jogador_atual = player_keys[idx - 1]
			var acao = selecoes.get(jogador_atual, "")
			current_index = panels.find(panel_dict.get(acao, panels[0]))
			_focus_current_panel()

func _iniciar_selecao():
	selecao_ativa = true
	selecao_finalizada = false
	current_index = 0
	jogador_atual = player_keys[0] if player_keys.size() > 0 else ""
	selecoes.clear()
	submenu_resultados.clear()
	itemMenu.atualizar_itemlist()
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
					var resultado = await personagens.menuPersonagens(true)
					if resultado < 0:
						_focus_current_panel()
						_fechar_submenu()
						return
						
					submenu_resultados[jogador_atual] = resultado
					_confirmar_acao(nome, resultado)
					_fechar_submenu()
				"ITM":
					submenu_ativo = true
					var resultado = await itemMenu.itemsIvt()
					if resultado < 0:
						_focus_current_panel()
						_fechar_submenu()
						return
						
					submenu_resultados[jogador_atual] = resultado
					_confirmar_acao(nome, resultado)
					_fechar_submenu()

func _confirmar_acao(nome: String, _dados_extra = null) -> void:
	selecoes[jogador_atual] = nome
	var idx = player_keys.find(jogador_atual)
	
	if idx >= 0 and idx < player_keys.size() - 1:
		jogador_atual = player_keys[idx + 1]
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
		
		#for enemie in enemiesNodes:
			#enemie.apply_damage(randi_range(Manager.PlayersAtuais[key].maxdamage, Manager.PlayersAtuais[key].mindamage))
			#enemie.apply_damage(Manager.PlayersAtuais[key].maxdamage)
	
	elif act == "DEF":
		pass
	
	elif act == "EXE":
		pass
	
	elif act == "ITM":
		if not submenu_resultados.has(key):
			return
			
		var resultado = submenu_resultados[key]
		#if resultado["index"] < Manager.CurrentInventory.get_in_items_batalha().size():
		for player in Manager.PlayersAtuais.keys():
			Manager.CurrentInventory.use_item_in_batalha(resultado, player)
			
		Manager.CurrentInventory.remove_item_in_batalha(resultado)
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
	for inimigo in enemiesNodes:
		inimigo.atacar()
	await get_tree().create_timer(enemiesNodes.pick_random().time).timeout
	Manager.change_state(Manager.GameState.BATTLE_MENU)

func end_batalha() -> void:
	if enemiesNodes.size() > 0:
		return
	
	await get_tree().create_timer(2.0).timeout
	Manager.tocar_musica()
	batalha.dungeons2D.end_batalha.emit()
	queue_free()

func dead_batalha() -> void:
	await get_tree().create_timer(0.0).timeout
	Manager.tocar_musica()
	Manager.Game_Over()
	queue_free()

func adicionar_jogador(index: int, key: String) -> void:
	var playerload = load(PlayersDIR[key].PlayerBatalhaPath)
	var playerinst: PlayerBase2D = playerload.instantiate()
	playersNodes.append(playerinst)
	playerinst.id = playersNodes.size() - 1
	playerinst.rootbatalha = self
	playerinst.player = key
	playerinst.position = personagens.playerMarker2D[index].position
	paneis_players[index].player = key
	paneis_players[index].visible = true
	personagens.spritesP[index].position.x = playerinst.size_marker
	personagens.add_child(playerinst)

func adicionar_inimigo(inimigo: PackedScene, intex: int) -> void:
	var inim: EnemiesBase2D = inimigo.instantiate()
	enemiesNodes.append(inim)
	inim.id = enemiesNodes.size() - 1
	inim.rootbatalha = self
	inim.rootobjeto = battle_arena.objetos
	inim.position = personagens.inimigoMarker2D[intex].position
	personagens.spritesI[intex].position.x = inim.size_marker
	personagens.add_child(inim)
	inim.play("default")

func remover_jogador(_key: String) -> void:
	pass

func remover_inimigo(index: int) -> void:
	if enemiesNodes.size() > 0:
		enemiesNodes.remove_at(index)

func _verificar_dead() -> bool:
	var play: int = 0
	for i in playersNodes:
		if i.fallen:
			play += 1
	if play == playersNodes.size():
		return true
	return false
