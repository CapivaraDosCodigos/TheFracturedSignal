extends Node

#region variables

enum GameState { MAP, BATTLE, CUTSCENES, DIALOGUE, BATTLE_MENU, NOT_IN_THE_GAME, SAVE_MENU}
var GameStateString := GameState.keys()
const batalha2d: PackedScene = preload("res://Areais/Batalha/cenas/BATALHA.tscn")

@onready var fps_label: Label = %fps_label
@onready var Menu: CanvasLayer = $MENU
@onready var audio: AudioPlayer = $AudioPlayerZ
@onready var audio2: AudioPlayer = $AudioPlayerS

@export var current_status: GameState = GameState.MAP

@export_range(0, 100) var volumedebug: int = 100

var raio: RayCast2D; var Body: Node; var ObjectPlayer: ObjectPlayer2D

var textureD: Texture = null; var materialD: ShaderMaterial = null

var Data: SeasonResource; var Extras: DataExtras; var CurrentScene: PackedScene
var CurrentPlayer: PlayerData; var CurrentInventory: Inventory
var PlayersAtuais: Dictionary[String, PlayerData]; var CurrentPlayerString: String
var CurrentSlot: int; var CurrentTemporada: int
var InGame: bool = false

#endregion

func esperardialogo() -> void:
	await get_tree().create_timer(0.5).timeout
	change_state(GameState.MAP)

func change_state(estado: GameState) -> void:
	current_status = estado

func tocar_musica(caminho: String = "", volume: float = 100.0, loop: bool = true, atraso: float = 0.0, canal: int = 1) -> void:
	var canais = {1: audio, 2: audio2}
	if canais.has(canal):
		canais[canal].tocar_musica(caminho, volume, loop, atraso)
	else:
		push_warning("Canal %s inexistente!" % canal)

func StartBatalha(batalha: DataBatalha, pos: Vector2 = Vector2.ZERO) -> void:
	var batalhaInstantiante := batalha2d.instantiate()
	tocar_musica("res://sons/sounds/Deltarune - Sound Effect Battle Start Jingle(MP3_160K).mp3", 100, false, 0.0, 2)
	batalha.dungeons2D.iniciar_batalha()
	batalhaInstantiante.batalha = batalha
	batalhaInstantiante.global_position = pos
	get_tree().root.add_child(batalhaInstantiante)

func DialogoTexture(texture: String = "", material: String = "") -> void:
	if texture == "":
		textureD = null
	else:
		textureD = load(texture)
	
	if material == "":
		materialD = null
	else:
		materialD = load(material)

func SAVE(slot: int) -> void:
	Data.Extras = Extras
	Data.CurrentScene = CurrentScene
	Data.CurrentPlayer = CurrentPlayerString
	Data.CurrentInventory = CurrentInventory.duplicate(true)
	Data.PlayersAtuais = PlayersAtuais.duplicate(true)
	
	SaveData.Salvar(slot, Data)

func Start_Save(slot: int, temporada: int, debug: bool = false) -> void:
	await get_tree().process_frame
	_clear()
	
	Data = SaveData.Carregar(slot, temporada)
	Extras = Data.Extras
	CurrentScene = Data.CurrentScene
	CurrentPlayerString = Data.CurrentPlayer
	CurrentInventory = Data.CurrentInventory
	PlayersAtuais = Data.PlayersAtuais
	Data.slot = slot
	CurrentSlot = slot
	CurrentTemporada = temporada
	
	_atualisar_propriedades()
	
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

func IsCurrentPlayer(player: PlayerData) -> void:
	AdicionarPlayer(player)
	CurrentPlayer = player

func AdicionarPlayer(player: PlayerData) -> void:
	if not PlayersAtuais.has(player.Nome):
		PlayersAtuais[player.Nome] = player

func RemoverPlayer(player: String) -> void:
	if PlayersAtuais.has(player):
		PlayersAtuais.erase(player)

func InGameIsTrue() -> void:
	while not InGame:
		await get_tree().process_frame

func _process(_delta: float) -> void:
	var camada: int
	
	if ObjectPlayer != null:
		camada = ObjectPlayer.camada
	
	Global.configures.music = volumedebug
	
	fps_label.text = "FPS: " + str(Engine.get_frames_per_second()) + ", CurrentStatus: " + GameStateString[current_status] + ", camada: " + str(camada)
	
	if raio != null:
		if Input.is_action_just_pressed("confirm"):
			if raio.is_colliding():
				Body = raio.get_collider()
		else:
			Body = null
	else:
		Body = null

func _ready() -> void:
	#Start_Save(1, true)
	var _shader_material := preload("res://texture/folderTres/materials/preto_&_branco.tres")
	var _path := "res://texture/PNG/icon/icon_sheet_32x32.png"
	#var _path2 := "res://texture/PNG/funds/Border All 3.png"
	#print(Starts.ZenoData.armorE)
	#Database.equip_armor(Starts.InvData, Starts.ZenoData, 2)
	#print(Starts.ZenoData.armorE)
	#salvar_print_visivel()
	#$time.aplicar_material_e_salvar(_path, _shader_material)
	#$time.aplicar_material_e_salvar(_path2, _shader_material)

#func _process(_delta: float) -> void:
	#if InGame:
		#return
	
	#_atualisar_propriedades()

func _clear(slotON: bool = false) -> void:
	Data = null
	Extras = null
	CurrentScene = null
	CurrentInventory = null
	CurrentPlayer = null
	CurrentPlayerString = ""
	CurrentInventory = null
	
	for key in PlayersAtuais.keys():
		PlayersAtuais[key].reset()
	PlayersAtuais.clear()
	
	if not slotON:
		CurrentSlot = 0
		CurrentTemporada = 0

func _atualisar_propriedades():
	print(PlayersAtuais)
	
	CurrentPlayer = PlayersAtuais.get(CurrentPlayerString, null)
	if CurrentPlayer == null:
		push_warning("CurrentPlayerString inválido: %s" % CurrentPlayerString)
	
	for key in PlayersAtuais.keys():
		PlayersAtuais[key].update_properties()
