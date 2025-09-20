@icon("res://texture/folderTres/texturas/batalha.tres")
class_name Batalha2D extends Node2D

# NÃO ABRIR ESSE NEGÓCIO DIRETAMENTE

#region variables 

@export var anim: AnimationPlayer
@export var personagens: Node2D 
@export var itemMenu: MarginContainer

@onready var ATK := %panel1; @onready var ITM := %panel2; @onready var EXE := %panel3; @onready var DEF := %panel4; @onready var MRC := %panel5
@onready var markerI: Array[Marker2D] = [ $BatalhaCanvas/Personagens/inimigo1, $BatalhaCanvas/Personagens/inimigo2, $BatalhaCanvas/Personagens/inimigo3 ]
@onready var playerI: Array[AnimatedSprite2D] = [ $BatalhaCanvas/Personagens/player1, $BatalhaCanvas/Personagens/player2, $BatalhaCanvas/Personagens/player3 ]

const MAX_ENENINES: int = 3

var last_state = null
var submenu_resultados: Dictionary
var PlayersDIR: Dictionary[String, PlayerData]
var panel_dict: Dictionary[String, Control]
var batalha: DataBatalha
var panels: Array[Control]
var selecoes: Array[String]
var enemies: Array[EnemiesBase2D] = []
var players: int = 1
var current_index: int = 0
var jogador_atual: int = 0
var selecao_ativa: bool = false
var selecao_finalizada: bool = false
var submenu_ativo: bool = false

#endregion

func _ready() -> void:
	Manager.nova_palette("", false)
	while batalha.inimigos.size() > MAX_ENENINES:
		batalha.inimigos.pop_back()
	
	PlayersDIR = Starts.PlayersAtuais
	players = PlayersDIR.size()
	var keys = PlayersDIR.keys()
	for idx in range(keys.size()):
		var key = keys[idx]
		adicionar_jogador(idx, key)
	
	for i in range(batalha.inimigos.size()):
		adicionar_inimigo(batalha.inimigos[i], markerI[i].position)
	
	panels = [ATK, ITM, EXE, DEF, MRC]
	panel_dict = {"ATK": ATK,"ITM": ITM,"EXE": EXE,"DEF": DEF,"MRC": MRC}
	
	await get_tree().create_timer(1.5).timeout
	
	DialogueManager.show_example_dialogue_balloon(load(batalha.dialogo), batalha.start_dialogo)
	Manager.tocar_musica_manager(batalha.caminho, batalha.volume, batalha.loop)

func _process(_delta: float) -> void:
	var current_state = Manager.current_status
	if current_state != last_state:
		if current_state == Manager.GameState.BATTLE:
			#$"%Ambição".position = $%BATTLE_ARENA.position
			anim.play("S_panel")
			print("battle")
			_exe_atacar()
			
		elif current_state == Manager.GameState.BATTLE_MENU:
			anim.play("E_panel")
			print("menu_battle")
			_iniciar_selecao()
		
		last_state = current_state

func _unhandled_input(event: InputEvent) -> void:
	if not selecao_ativa or selecao_finalizada:
		return
	
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
			var acao = selecoes[jogador_atual]
			if acao in panel_dict:
				current_index = panels.find(panel_dict[acao])
			else:
				current_index = 0
			_focus_current_panel()

func _iniciar_selecao():
	print(enemies.size())
	selecao_ativa = true; selecao_finalizada = false
	jogador_atual = 0; current_index = 0
	selecoes = []
	selecoes.resize(players)
	submenu_resultados = {}
	itemMenu.atualizar_itemlist()
	_focus_current_panel()

func _abrir_submenu(panel: Control) -> void:
	current_index = 0
	for nome in panel_dict:
		if panel_dict[nome] == panel:
			if nome == "ATK":
				_confirmar_acao(nome)
				
			elif nome == "DEF":
				_confirmar_acao(nome)
				
			elif nome == "EXE":
				_confirmar_acao(nome)
				
			elif nome == "ITM":
				submenu_ativo = true
				var resultado = await itemMenu.itemsIvt()
				if resultado == null or resultado["index"] < 0:
					_focus_current_panel()
					_fechar_submenu()
					return
					
				submenu_resultados[jogador_atual] = resultado
				_confirmar_acao(nome, resultado)
				_fechar_submenu()
				
			elif nome == "MRC":
				_confirmar_acao(nome)

func _confirmar_acao(nome: String, _dados_extra = null) -> void:
	selecoes[jogador_atual] = nome
	jogador_atual += 1
	
	if jogador_atual >= players:
		selecao_ativa = false
		selecao_finalizada = true
		for i in range(players):
			_act(selecoes[i], i)
		Manager.change_state(Manager.GameState.BATTLE)
	else:
		current_index = 0
		_focus_current_panel()

func _act(act: String, ent: int) -> void:
	#print("- Jogador %d: %s" % [ent + 1, act])
	
	if act == "ATK":
		for i in enemies:
			i.life -= 10
			#print("Atacar inimigo, vida: %d" % i.life)
	
	elif act == "DEF":
		#print("Defender")
		pass
	
	elif act == "EXE":
		#print("Executar")
		pass
	
	elif act == "ITM":
		if submenu_resultados.has(ent):
			var resultado = submenu_resultados[ent]
			#print("Jogador ", ent + 1, " usou: ", resultado["texto"], " (índice:", resultado["index"], ")")
			
			if resultado["index"] < Starts.CurrentInventory.items.size():
				Starts.CurrentInventory.remove_item_in_batalha(resultado["index"])
				itemMenu.atualizar_itemlist()
	
	elif act == "MRC":
		#print("Mercy")
		pass
	
	else :
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
	for inimigo in enemies:
		inimigo.atacar()
	await get_tree().create_timer(enemies.pick_random().time).timeout
	Manager.change_state(Manager.GameState.BATTLE_MENU)

func end_batalha() -> void:
	if enemies.size() > 0:
		return
		
	batalha.dungeons2D.end_batalha.emit()
	Manager.tocar_musica_manager()
	queue_free()

func adicionar_jogador(index: int, key: String) -> void:
	playerI[index].sprite_frames = PlayersDIR[key].Anime
	playerI[index].material = PlayersDIR[key].MaterialP
	playerI[index].play("default")

func adicionar_inimigo(inimigo: PackedScene, pos: Vector2) -> void:
	var inim = inimigo.instantiate()
	personagens.add_child(inim)
	inim.id = enemies.size() - 1
	inim.rootbatalha = self
	inim.position = pos
	enemies.append(inim)
	inim.play("default")

func remover_jogador(_key: String) -> void:
	pass

func remover_inimigo(index: int) -> void:
	enemies.remove_at(index)
