@icon("res://Resources/texturas/global.tres")
extends CanvasLayer

const GLOBAl_PATH: String = "user://configures.tres"

@onready var audios: Dictionary[int, AudioPlayer] = { 1: $AudioPlayerS, 2: $AudioPlayerZ }
@onready var animation_global: AnimationPlayer = $AnimationGlobal
@onready var gamepad: Node2D = $Gamepad

var musica: float = 100:
	set(value):
		musica = value
		set_volume("music", musica)
var efeito: float = 100:
	set(value):
		efeito = value
		set_volume("effects", efeito)

var configures: DataConf = DataConf.new()
var AllAudios: Array[AudioPlayer] = []

func _ready() -> void:
	configures = Carregar_Arquivo()
	musica = configures.music
	efeito = configures.sound_effects
	
	gamepad.modulate = Color(1.0, 1.0, 1.0, 0.0025 * configures.hub)
	
	set_window_OS()

func Carregar_Arquivo() -> DataConf:
	if not ResourceLoader.exists(GLOBAl_PATH):
		return DataConf.new()
	
	var conf = ResourceLoader.load(GLOBAl_PATH)
	return conf

func Salvar_Arquivo() -> void:
	configures.music = musica
	configures.sound_effects = efeito
	
	var err: int = ResourceSaver.save(configures, GLOBAl_PATH)
	if err != OK:
		push_error("❌ Falha ao salvar. Código de erro: %s" % [err])
	else:
		print("💾 Dados salvos")

func set_window_OS() -> void:
	match OS.get_name():
		"Windows":
			set_window(960, 540)
			gamepad.visible = false
			print("Welcome to Windows!")
			
		"macOS":
			set_window(960, 540)
			gamepad.visible = false
			print("Welcome to macOS!")
			
		"Linux", "FreeBSD", "NetBSD", "OpenBSD", "BSD":
			set_window(960, 540)
			gamepad.visible = false
			print("Welcome to Linux/BSD!")
			
		"Android":
			set_window(1152, 540)
			gamepad.visible = true
			print("Welcome to Android!")
			
		"iOS":
			set_window(1152, 540)
			gamepad.visible = true
			print("Welcome to iOS!")
			
		"Web":
			set_window(960, 540)
			gamepad.visible = false
			print("Welcome to the Web!")
		
		_:
			print("Erro, dispositivel nao encontrado!")

func Tocar_Musica(DataAudio: DataAudioPlayer, canal: int = 1) -> void:
	if audios.has(canal):
		audios[canal].tocar(DataAudio)
	else:
		push_warning("Canal %s inexistente!" % canal)

func set_volume(tipo: String, valor: float) -> void:
	valor = clamp(valor, 0.0, 100.0)
	match tipo:
		"music":
			configures.music = valor
		"effects":
			configures.sound_effects = valor
		_:
			push_warning("⚠️ Tipo de volume desconhecido: " + tipo)
			return
	
	for audio: AudioPlayer in AllAudios:
		audio.atualizar_volume()

func play_transition(anim: String) -> float:
	animation_global.play(anim)
	return animation_global.get_animation(anim).length

func test_node(node: Node2D) -> void:
	var pos: Vector2 = DataUtilities.world_to_screen(node)
	$Sprite2D.global_position = pos

func set_window(width: int, height: int ) -> void:
	var size: Vector2i = Vector2i(width, height)
	DisplayServer.window_set_size(size)
	get_viewport().content_scale_size = size
