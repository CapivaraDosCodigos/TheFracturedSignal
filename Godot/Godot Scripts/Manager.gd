extends Node

#region variables

enum GameState { MAP, BATTLE, CUTSCENES, DIALOGUE, BATTLE_MENU, NOT_IN_THE_GAME, SAVE_MENU}
const batalha2d: PackedScene = preload("res://Areais/Batalha/cenas/SIMPLES_BATALHA.tscn")

@onready var fps_label: Label = %fps_label
@onready var Menu: CanvasLayer = $MENU
@onready var audios: Dictionary[int, AudioPlayer] = { 1: $AudioPlayerS, 2: $AudioPlayerZ }

@export var current_status: GameState = GameState.MAP

var raio: RayCast2D; var Body: Node; var ObjectPlayer: ObjectPlayer2D
var GameStateString := GameState.keys()
var textureD: Texture = null

var Data: SeasonResource; var Extras: DataExtras; var CurrentScene: PackedScene
var CurrentPlayer: PlayerData; var CurrentPlayerString: String
var PlayersAtuais: Dictionary[String, PlayerData]
var CurrentSlot: int; var CurrentTemporada: int
var InGame: bool = false

#endregion

func test():
	PlayersAtuais[CurrentPlayerString].InventoryPlayer.add_item(Database.SIGNAL_WEAPON)

func esperardialogo() -> void:
	await get_tree().create_timer(0.5).timeout
	change_state(GameState.MAP)

func change_state(estado: GameState) -> void:
	current_status = estado

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

func get_Inventory() -> Inventory:
	return PlayersAtuais[CurrentPlayerString].InventoryPlayer

func _process(_delta: float) -> void:
	fps_label.text = "FPS: " + str(Engine.get_frames_per_second()) + ", CurrentStatus: " + GameStateString[current_status] + ", slot: " + str(CurrentSlot)
	
	if raio != null:
		if Input.is_action_just_pressed("confirm"):
			if raio.is_colliding():
				Body = raio.get_collider()
		else:
			Body = null
	else:
		Body = null
	
	#if InGame and current_status != GameState.NOT_IN_THE_GAME:
		#_atualisar_propriedades()

func _clear(slotON: bool = false) -> void:
	Data = null
	Extras = null
	CurrentScene = null
	CurrentPlayer = null
	CurrentPlayerString = ""
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
