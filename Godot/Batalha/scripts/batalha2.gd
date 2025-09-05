extends Node

#region variables 

@export_group("Nodes")
@export var anim: AnimationPlayer
@export_group("Inimigos")
@export var inimigos: Array[EnemiesBase] = [EnemiesBase.new()]

@onready var ATK := %panel1; @onready var ITM := %panel2; @onready var EXE := %panel3; @onready var DEF := %panel4; @onready var MRC := %panel5
@onready var inimigosI: Array[AnimatedSprite2D] = [ $BatalhaCanvas/Personagens/inimigo1, $BatalhaCanvas/Personagens/inimigo2, $BatalhaCanvas/Personagens/inimigo3 ]
@onready var playerI: Array[AnimatedSprite2D] = [ $BatalhaCanvas/Personagens/player1, $BatalhaCanvas/Personagens/player2, $BatalhaCanvas/Personagens/player3 ]
@onready var itemMenu: MarginContainer = $BatalhaCanvas/Control/VBoxContainer/HBoxContainer/MarginContainer

const MAX_ENENINES: int = 3

var last_state = null; var submenu_resultado = null
var PlayersDIR: Dictionary; var panel_dict: Dictionary; var batalha: DataBatalha
var panels: Array; var selecoes: Array
var players: int = 1; var current_index: int = 0; var jogador_atual: int = 0
var selecao_ativa: bool = false; var selecao_finalizada: bool = false; var submenu_ativo: bool = false

#endregion

func _ready() -> void:
	batalha = Manager.batalha
	Manager.tocar_musica_manager("res://sons/music/battle_vapor.ogg", 90, true, 0.0)
	Manager.nova_palette("", false)
	DialogueManager.show_example_dialogue_balloon(load("res://Godot/Diálogos/bebedouro.dialogue"), "bebedouro")
	while inimigos.size() > MAX_ENENINES:
		inimigos.pop_back()
	if Starts.Pdir:
		PlayersDIR = Starts.Pdir
		players = Starts.Pdir.size()
		var keys = PlayersDIR.keys()
		for idx in range(keys.size()):
			var key = keys[idx]
			playerI[idx].sprite_frames = PlayersDIR[key].Anime
			playerI[idx].material = PlayersDIR[key].MaterialP
			playerI[idx].play("default")
	
	for idx in range(inimigos.size()):
		inimigosI[idx].sprite_frames = inimigos[idx].Anime
		inimigosI[idx].material = inimigos[idx].MaterialI
		inimigosI[idx].play("default")
	
	panels = [ATK, ITM, EXE, DEF, MRC]
	panel_dict = {"ATK": ATK,"ITM": ITM,"EXE": EXE,"DEF": DEF,"MRC": MRC}

func _process(_delta: float) -> void:
	batalha = Manager.batalha
	var current_state = Manager.current_status
	if current_state != last_state:
		match current_state:
			Manager.GameState.BATTLE:
				#$"%Ambição".position = $%BATTLE_ARENA.position
				anim.play("S_panel")
				_exe_atacar()
				
			Manager.GameState.BATTLE_MENU:
				anim.play("E_panel")
				_iniciar_selecao()
	
		last_state = current_state

func _exe_atacar():
	for inimigo in inimigos:
		inimigo.atacar()
		await get_tree().create_timer(inimigos.pick_random().time).timeout # probema
		Manager.change_state(Manager.GameState.BATTLE_MENU)

func _iniciar_selecao():
	selecao_ativa = true
	selecao_finalizada = false
	jogador_atual = 0
	current_index = 0
	selecoes = []
	selecoes.resize(players)
	_atualizar_itemlist()
	_focus_current_panel()

func _unhandled_input(event: InputEvent) -> void:
	if not selecao_ativa or selecao_finalizada:
		return
	
	
	
	# Se um submenu está aberto, ele que controla input
	if submenu_ativo:
		if event.is_action_pressed("cancel"):
			_fechar_submenu()
		return
	
	if event.is_action_pressed("Right"):
		if not current_index == panels.size() - 1:
			current_index = (current_index + 1) % panels.size()
			_focus_current_panel()
		
	elif event.is_action_pressed("Left"):
		if not current_index == 0:
			current_index = (current_index - 1 + panels.size()) % panels.size()
			_focus_current_panel()
	
	elif event.is_action_pressed("confirm"):
		_abrir_submenu(panels[current_index])

	elif event.is_action_pressed("cancel"):
		if players > 1 and jogador_atual > 0 and not selecao_finalizada:
			jogador_atual -= 1
			current_index = selecoes[jogador_atual]
			_focus_current_panel()

func _abrir_submenu(panel: Control) -> void:
	current_index = 0
	for nome in panel_dict:
		if panel_dict[nome] == panel:
			match nome:
				"ATK":
					_confirmar_acao(nome) # ATK não precisa submenu
				"DEF":
					_confirmar_acao(nome) # DEF não precisa submenu
				"EXE":
					_confirmar_acao(nome)
				"ITM":
					submenu_ativo = true
					var resultado = await itemMenu.itemsIvt()
					submenu_resultado = resultado
					_confirmar_acao(nome, submenu_resultado)
					_fechar_submenu()
				"MRC":
					_confirmar_acao(nome)

func _fechar_submenu() -> void:
	submenu_ativo = false
	submenu_resultado = null
	
	itemMenu.cancel()
	
	_focus_current_panel()

func _confirmar_acao(nome: String, _dados_extra = null) -> void:
	selecoes[jogador_atual] = nome
	jogador_atual += 1

	if jogador_atual >= players:
		selecao_ativa = false
		selecao_finalizada = true
		print("Todos os jogadores confirmaram:")
		for i in range(players):
			await _act(selecoes[i], i)
		Manager.change_state(Manager.GameState.BATTLE)
	else:
		current_index = 0
		_focus_current_panel()

func _focus_current_panel():
	if selecao_ativa and panels[current_index]:
		await get_tree().process_frame
		panels[current_index].grab_focus()

func _act(act: String, ent: int, _enem: int = 0):
	print("- Jogador %d: %s" % [ent + 1, act])
	match act:
		"ATK":
			print("Atacar inimigo")
		"DEF":
			print("Defender")
		"EXE":
			print("Executar")
		"ITM":
			print("Usar item:", submenu_resultado)
			Starts.InvData.itens.remove_at(submenu_resultado["index"])
		"MRC":
			print("Mercy")
		_:
			print("erro")

func _atualizar_itemlist():
	%ItemList.clear()
	for item in Starts.InvData.itens:
		%ItemList.add_item(item.nome, item.icone)
