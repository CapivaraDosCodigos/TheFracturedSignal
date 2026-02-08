@icon("res://texture/PNG/icon/godot/device-gamepad-2.svg")
extends Node

#region variables

enum GameState { MAP, BATTLE, CUTSCENES, DIALOGUE, BATTLE_MENU, NOT_IN_THE_GAME, SAVE_MENU, MENU }
const BATALHA_SCENE: PackedScene = preload("res://Areais/Batalha/cenas/BATALHASave1.tscn")

@onready var audios: Dictionary[int , AudioPlayer] = { 1: $AudioPlayerS, 2: $AudioPlayerZ, 3: $AudioPlayer5 }
@onready var fps_label: Label = %fps_label
@onready var Menu: CanvasLayer = $MENU

@export var CurrentStatus: GameState = GameState.NOT_IN_THE_GAME

var GameStateString: Array = GameState.keys()

var NodeVariant: Node
var textureD: Texture
var raio: RayCast2D
var Body: Node

var PlayersAtuais: Dictionary[String, PlayerData]
var ObjectPlayer: ObjectPlayer2D
var CurrentBatalha: Batalha2D
var Data: SeasonResource
var Extras: DataExtras

var CurrentPlayer: String = ""
var CurrentScene: String = ""
var CurrentTemporada: int = 1
var CurrentSlot: int = 0
var InGame: bool = false

#endregion

func get_Player(nome: String = CurrentPlayer) -> PlayerData:
	if PlayersAtuais.has(nome):
		return PlayersAtuais.get(nome)
	#push_error("Jogador '%s' não encontrado!" % nome)
	return null

func get_Inventory(nome: String = CurrentPlayer) -> Inventory:
	var player: PlayerData = get_Player(nome)
	return player.InventoryPlayer if player != null else null

func set_state(estado: String, espera: float = 0.0) -> void:
	estado = estado.strip_edges().to_upper()

	if GameStateString.has(estado):
		if espera > 0:
			await get_tree().create_timer(espera).timeout
		CurrentStatus = GameState[estado]
	else:
		push_warning("⚠️ Estado inválido: '%s'" % estado)

func isState(estado: String) -> bool:
	estado = estado.strip_edges().to_upper()
	if GameStateString.has(estado):
		if CurrentStatus == GameState[estado]:
			return true
		return false
	else:
		push_warning("⚠️ Estado inválido: '%s'" % estado)
		return false

func tocar_musica(DataAudio: DataAudioPlayer, canal: int = 1) -> void:
	if audios.has(canal):
		audios[canal].tocar(DataAudio)
	else:
		push_warning("Canal %s inexistente!" % canal)

func StartBatalha(batalhaData: DataBatalha, pos: Vector2 = Vector2.ZERO):
	await get_tree().process_frame
	var instBatalha: Batalha2D = BATALHA_SCENE.instantiate()
	tocar_musica(PathsMusic.SOUND_EFFECT_BATTLE_START_JINGLE)
	batalhaData.dungeons2D.iniciar_batalha()
	instBatalha.batalha = batalhaData
	instBatalha.global_position = pos
	CurrentBatalha = instBatalha
	get_tree().root.add_child(instBatalha)

func DialogoTexture(texture: String = ""):
	textureD = load(texture) if texture != "" else null

func SAVE(slot: int):
	await get_tree().process_frame
	
	Data.Extras = Extras
	Data.CurrentScene = CurrentScene
	Data.CurrentPlayer = CurrentPlayer
	
	SaveData.Salvar(slot, Data)

func Start_Save(slot: int, temporada: int, debug: bool = false):
	await get_tree().process_frame
	_clear()

	Data = SaveData.Carregar(slot, temporada)
	Extras = Data.Extras
	CurrentScene = Data.CurrentScene
	CurrentPlayer = Data.CurrentPlayer
	CurrentSlot = slot
	CurrentTemporada = temporada
	PlayersAtuais = Data.get_players()
	for player: PlayerData in PlayersAtuais.values():
		player.reset()
	
	if not debug:
		if CurrentScene:
			get_tree().change_scene_to_file(CurrentScene)
		else:
			get_tree().change_scene_to_file(Data.StartScene)

	InGame = true

func Game_Over() -> void:
	await get_tree().process_frame
	_clear(true)
	get_tree().change_scene_to_file("res://Godot/Godot Cenas/dead.tscn")

func Return_To_Title() -> void:
	await get_tree().process_frame
	set_state("NOT_IN_THE_GAME")
	_clear(true)
	get_tree().change_scene_to_file("res://Godot/Godot Cenas/intro.tscn")

func InGameIsTrue():
	while not InGame:
		await get_tree().process_frame

#func _ready() -> void:
	#$time.aplicar_material_e_salvar("res://texture/paleta/PaletaDeCores.png" , load("res://shader/testtop.tres"))

func _process(_delta):
	fps_label.text = "FPS: %s | Estado: %s | slot: %s" % [Engine.get_frames_per_second(), GameStateString[CurrentStatus], CurrentSlot]
	#fps_label.text = "FPS: %s" % [Engine.get_frames_per_second()]
	fps_label.visible = Global.configures.fps_bool
	
	if raio:
		if Input.is_action_just_pressed("confirm") and raio.is_colliding():
			Body = raio.get_collider()
		else:
			Body = null

func _clear(slotON: bool = false):
	CurrentBatalha = null
	ObjectPlayer = null
	textureD = null
	Extras = null
	Data = null
	raio = null
	Body = null
	CurrentPlayer = ""
	CurrentScene = ""
	PlayersAtuais.clear()
	
	if not slotON:
		CurrentSlot = 0
		CurrentTemporada = 0
