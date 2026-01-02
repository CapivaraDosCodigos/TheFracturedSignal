extends Node

#region variables

enum GameState { MAP, BATTLE, CUTSCENES, DIALOGUE, BATTLE_MENU, NOT_IN_THE_GAME, SAVE_MENU, MENU }
const BATALHA_SCENE: PackedScene = preload("res://Areais/Batalha/cenas/BATALHA.tscn")

@onready var audios: Dictionary[int , AudioPlayer] = { 1: $AudioPlayerS, 2: $AudioPlayerZ, 3: $AudioPlayer5 }
@onready var fps_label: Label = %fps_label
@onready var Menu: CanvasLayer = $MENU

@export var current_status: GameState = GameState.MAP
@export var Sound_Battle: DataAudioPlayer = DataAudioPlayer.new()

var ObjectPlayer: ObjectPlayer2D = null
var textureD: Texture = null
var raio: RayCast2D = null
var Body: Node = null

var PlayersAtuais: Dictionary[String, PlayerData] = {}

var GameStateString := GameState.keys()

var CurrentBatalha: Batalha2D
var CurrentScene: PackedScene
var Data: SeasonResource
var Extras: DataExtras

var CurrentPlayerString: String = ""
var CurrentTemporada: int = 1
var CurrentSlot: int = 0
var InGame: bool = false

#endregion

func test():
	get_Player().InventoryPlayer.add_item(Database.SIGNAL_WEAPON)

func get_Player(nome: String = CurrentPlayerString) -> PlayerData:
	if PlayersAtuais.has(nome):
		PlayersAtuais[nome].update_properties()
		return PlayersAtuais[nome]
	push_error("Jogador '%s' não encontrado!" % nome)
	return null

func get_Inventory(nome: String = CurrentPlayerString) -> Inventory:
	var player: PlayerData = get_Player(nome)
	return player.InventoryPlayer if player != null else null

func change_state(estado: String, espera: float = 0.0) -> void:
	estado = estado.strip_edges().to_upper()

	if GameStateString.has(estado):
		if espera > 0:
			await get_tree().create_timer(espera).timeout
		current_status = GameState[estado]
	else:
		push_warning("⚠️ Estado inválido: '%s'" % estado)

func isState(estado: String) -> bool:
	estado = estado.strip_edges().to_upper()
	if GameStateString.has(estado):
		if current_status == GameState[estado]:
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
	var instBatalha: Batalha2D = BATALHA_SCENE.instantiate()
	tocar_musica(Sound_Battle)
	batalhaData.dungeons2D.iniciar_batalha()
	instBatalha.batalha = batalhaData
	instBatalha.global_position = pos
	CurrentBatalha = instBatalha
	get_tree().root.add_child(instBatalha)

func DialogoTexture(texture: String = ""):
	textureD = load(texture) if texture != "" else null

func SAVE(slot: int):
	_updatePlayers()
	
	Data.Extras = Extras
	Data.CurrentScene = CurrentScene
	Data.CurrentPlayer = CurrentPlayerString
	Data.PlayersAtuais = PlayersAtuais.duplicate_deep(Resource.DEEP_DUPLICATE_ALL)
	
	SaveData.Salvar(slot, Data)

func Start_Save(slot: int, temporada: int, debug: bool = false):
	await get_tree().process_frame
	_clear()

	Data = SaveData.Carregar(slot, temporada)
	Extras = Data.Extras
	CurrentScene = Data.CurrentScene
	CurrentPlayerString = Data.CurrentPlayer
	PlayersAtuais = Data.PlayersAtuais

	CurrentSlot = slot
	CurrentTemporada = temporada

	print(PlayersAtuais)
	_updatePlayers()
	
	if not debug:
		get_tree().change_scene_to_packed(CurrentScene)

	InGame = true

func Game_Over() -> void:
	await get_tree().process_frame
	_clear(true)
	get_tree().change_scene_to_file("res://Godot/Godot Cenas/dead.tscn")

func Return_To_Title() -> void:
	await get_tree().process_frame
	_clear(true)
	get_tree().change_scene_to_file("res://Godot/Godot Cenas/intro.tscn")

func AdicionarPlayer(player: PlayerData):
	if not PlayersAtuais.has(player.Nome):
		PlayersAtuais[player.Nome] = player

func RemoverPlayer(nome: String):
	PlayersAtuais.erase(nome)

func InGameIsTrue():
	while not InGame:
		await get_tree().process_frame

func _process(_delta):
	fps_label.text = "FPS: %s | Estado: %s | slot: %s" % [Engine.get_frames_per_second(), GameStateString[current_status], CurrentSlot]
	
	_updatePlayers()
	
	if raio:
		if Input.is_action_just_pressed("confirm") and raio.is_colliding():
			Body = raio.get_collider()
		else:
			Body = null

func _updatePlayers():
	for player in PlayersAtuais.values():
		player.update_properties()

func _clear(slotON: bool = false):
	Data = null
	Extras = null
	CurrentScene = null
	CurrentBatalha = null
	ObjectPlayer = null
	textureD = null
	raio = null
	Body = null
	CurrentPlayerString = ""
	PlayersAtuais.clear()

	if not slotON:
		CurrentSlot = 0
		CurrentTemporada = 0
