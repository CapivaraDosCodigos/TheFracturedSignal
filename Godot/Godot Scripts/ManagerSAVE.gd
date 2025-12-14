extends Node

#region variables

enum GameState { MAP, BATTLE, CUTSCENES, DIALOGUE, BATTLE_MENU, NOT_IN_THE_GAME, SAVE_MENU}
const batalha2d: PackedScene = preload("res://Areais/Batalha/cenas/SIMPLES_BATALHA.tscn")

@onready var audios: Dictionary[int, AudioPlayer] = { 1: $AudioPlayerS, 2: $AudioPlayerZ }
@onready var fps_label: Label = %fps_label
@onready var Menu: CanvasLayer = $MENU

@export var current_status: GameState = GameState.MAP

var ObjectPlayer: ObjectPlayer2D = null
var textureD: Texture = null
var raio: RayCast2D = null
var Body: Node = null

var GameStateString := GameState.keys()

var InGame: bool = false

var PlayersAtuais: Dictionary[String, PlayerData] = {}

var CurrentScene: PackedScene = null
var Data: SeasonResource = null
var Extras: DataExtras = null

var CurrentPlayerString: String = ""

var CurrentTemporada: int = 1
var CurrentSlot: int = 0

#endregion

#provisorio
func test():
	get_Player().InventoryPlayer.add_item(Database.SIGNAL_WEAPON)

func change_state(nome_estado: String, espera: float = 0.0) -> void:
	nome_estado = nome_estado.strip_edges().to_upper()
	
	if nome_estado in GameStateString:
		await get_tree().create_timer(espera).timeout
		current_status = GameState[nome_estado]
	else:
		push_warning("⚠️ Estado inválido: '%s'" % nome_estado)

func tocar_musica(caminho: String = "", volume: float = 100.0, loop: bool = true, atraso: float = 0.0, canal: int = 1, tipo: String = "music") -> void:
	if audios.has(canal):
		audios[canal].tocar(caminho, volume, loop, atraso, tipo)
	else:
		push_warning("Canal %s inexistente!" % canal)

func StartBatalha(batalha: DataBatalha, pos: Vector2 = Vector2.ZERO) -> void:
	var batalhaInstantiante := batalha2d.instantiate()
	tocar_musica("res://sons/sounds/Deltarune - Sound Effect Battle Start Jingle(MP3_160K).mp3", 100, false, 0.0, 2, "effects")
	batalha.dungeons2D.iniciar_batalha()
	batalhaInstantiante.batalha = batalha
	batalhaInstantiante.global_position = pos
	get_tree().root.add_child(batalhaInstantiante)

func DialogoTexture(texture: String = "") -> void:
	if texture == "":
		textureD = null
	else:
		textureD = load(texture)

func SAVE(slot: int) -> void:
	for key in PlayersAtuais.keys():
		get_Player(key).update_properties()
		get_Player(key).reset()
	
	Data.Extras = Extras
	Data.CurrentScene = CurrentScene
	Data.CurrentPlayer = CurrentPlayerString
	Data.PlayersAtuais = PlayersAtuais.duplicate_deep(Resource.DEEP_DUPLICATE_ALL)
	
	SaveData.Salvar(slot, Data)

func Start_Save(slot: int, temporada: int, debug: bool = false) -> void:
	await get_tree().process_frame
	_clear()
	
	Data = SaveData.Carregar(slot, temporada)
	Extras = Data.Extras
	CurrentScene = Data.CurrentScene
	CurrentPlayerString = Data.CurrentPlayer
	PlayersAtuais = Data.PlayersAtuais
	Data.slot = slot
	CurrentSlot = slot
	CurrentTemporada = temporada
	
	print(PlayersAtuais)
	for key in PlayersAtuais.keys():
		get_Player(key).update_properties()
		get_Player(key).reset()
	
	if not debug:
		get_tree().change_scene_to_packed(CurrentScene)
		
	InGame = true

func Return_To_Title() -> void:
	await get_tree().process_frame
	_clear(true)
	get_tree().change_scene_to_file("res://Godot/Godot Cenas/intro.tscn")

func Game_Over() -> void:
	await get_tree().process_frame
	_clear(true)
	get_tree().change_scene_to_file("res://Godot/Godot Cenas/dead.tscn")

func AdicionarPlayer(player: PlayerData) -> void:
	if not PlayersAtuais.has(player.Nome):
		PlayersAtuais[player.Nome] = player

func RemoverPlayer(player: String) -> void:
	if PlayersAtuais.has(player):
		PlayersAtuais.erase(player)

func InGameIsTrue() -> void:
	while not InGame:
		await get_tree().process_frame

func get_Inventory(nome: String = CurrentPlayerString) -> Inventory:
	return get_Player(nome).InventoryPlayer

func get_Player(nome: String = CurrentPlayerString) -> PlayerData:
	var player = PlayersAtuais[nome]
	player.update_properties()
	return player

func _process(_delta: float) -> void:
	fps_label.text = "FPS: " + str(Engine.get_frames_per_second()) + ", CurrentStatus: " + GameStateString[current_status]
	
	if raio != null:
		if Input.is_action_just_pressed("confirm"):
			if raio.is_colliding():
				Body = raio.get_collider()
		else:
			Body = null
	else:
		Body = null

func _clear(slotON: bool = false) -> void:
	Data = null
	Extras = null
	CurrentScene = null
	CurrentPlayerString = ""
	PlayersAtuais = {}
	
	if not slotON:
		CurrentSlot = 0
		CurrentTemporada = 0
