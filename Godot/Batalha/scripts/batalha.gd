extends Node

@export_group("Nodes")
@export var anim: AnimationPlayer
@export_group("Inimigos")
@export var inimigos: Array[EnemiesBase] = [EnemiesBase.new()]

@onready var ATK := %panel1; @onready var ITM := %panel2; @onready var EXE := %panel3; @onready var DEF := %panel4; @onready var MRC := %panel5
@onready var inimigosI: Array[AnimatedSprite2D] = [$Batalha/Personagens/inimigo1, $Batalha/Personagens/inimigo2, $Batalha/Personagens/inimigo3]
@onready var playerI: Array[AnimatedSprite2D] = [$Batalha/Personagens/player1, $Batalha/Personagens/player2, $Batalha/Personagens/player3]

const ALMA_POS: Vector2 = Vector2i(140, 60)
const MAX_ENENINES: int = 3

var last_state = null
var PlayersDIR: Dictionary; var panel_dict: Dictionary
var panels: Array; var selecoes: Array
var players: int; var current_index: int = 0; var jogador_atual: int = 0
var selecao_ativa: bool = false; var selecao_finalizada: bool = false

func _ready() -> void:
	Manager.tocar_musica_manager("res://sons/music/battle_vapor.ogg", 90, true, 0.0)
	Manager.nova_palette("", false)
	DialogueManager.show_example_dialogue_balloon(load("res://Godot/Diálogos/bebedouro.dialogue"), "bebedouro")
	while inimigos.size() > MAX_ENENINES:
		inimigos.pop_back()
	if Starts.Pdir != null:
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
	
	for i in range(Starts.InvData.itens.size()):
		var inv := Starts.InvData.itens
		$%ItemList.add_item(inv[i].nome, inv[i].icone)
	print(Starts.InvData.itens_battle)

func _process(_delta: float) -> void:
	var current_state = Manager.current_status
	if current_state != last_state:
		match current_state:
			Manager.GameState.BATTLE:
				#$"%Ambição".position = $%BATTLE_ARENA.position
				anim.play("S_panel")
				exe_atacar()
				
			Manager.GameState.BATTLE_MENU:
				anim.play("E_panel")
				iniciar_selecao()
	
		last_state = current_state
	
func iniciar_selecao():
	selecao_ativa = true
	selecao_finalizada = false
	jogador_atual = 0
	current_index = 0
	selecoes = []
	selecoes.resize(players)
	_focus_current_panel()

func _unhandled_input(event: InputEvent) -> void:
	if not selecao_ativa or selecao_finalizada:
		return
	
	if event.is_action_pressed("Right"):
		current_index = (current_index + 1) % panels.size()
		_focus_current_panel()
	
	elif event.is_action_pressed("Left"):
		current_index = (current_index - 1 + panels.size()) % panels.size()
		_focus_current_panel()
	
	elif event.is_action_pressed("confirm"):
		selecoes[jogador_atual] = current_index
		jogador_atual += 1
	
		if jogador_atual >= players:
			selecao_ativa = false
			selecao_finalizada = true
			print("Todos os jogadores confirmaram:")
			for i in players:
				var panel = panels[selecoes[i]]
				for nome in panel_dict:
					if panel_dict[nome] == panel:
						await act(nome, i)
						break
			Manager.change_state(Manager.GameState.BATTLE)

		else:
			current_index = 0
			_focus_current_panel()

	elif event.is_action_pressed("cancel"):
		if players > 1 and jogador_atual > 0 and not selecao_finalizada:
			jogador_atual -= 1
			current_index = selecoes[jogador_atual]
			_focus_current_panel()

func _focus_current_panel():
	if selecao_ativa and panels[current_index]:
		await get_tree().process_frame
		panels[current_index].grab_focus()

func act(_act: String, ent: int, enem: int = 0):
	print("- Jogador %d: %s" % [ent + 1, _act])
	match _act:
		"ATK":
			inimigos[0].life -= Database.apply_damage(PlayersDIR.values()[ent].maxdamage, inimigos[enem].defense)
			print(inimigos.get(enem))
			await get_tree().process_frame
		"DEF":
			print("jogador " + str(ent + 1) + " se denfendeu")
			await get_tree().process_frame
		"EXE":
			print("._.")
			await get_tree().process_frame
		"ITM":
			print("usar iventario")
			var menu = $%ItemList
			var resultado = await menu.itemsIvt()
			print("Jogador escolheu:", resultado.texto, " (índice:", resultado.index, ")")
		"MRC":
			print("._.")
			await get_tree().process_frame
		_:
			print("erro")
			await get_tree().process_frame

func exe_atacar():
	for inimigo in inimigos:
		inimigo.atacar()
	await get_tree().create_timer(inimigos.pick_random().time).timeout # probema
	Manager.change_state(Manager.GameState.BATTLE_MENU)
