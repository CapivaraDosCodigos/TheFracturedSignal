extends CanvasLayer

const GLOBAl_PATH: String = "user://configures.tres"

@onready var audios: Dictionary[int, AudioPlayer] = { 1: $AudioPlayerS, 2: $AudioPlayerZ }
@onready var animation_global: AnimationPlayer = $AnimationGlobal

@export_range(0.0, 100.0, 1) var musica: float = 100:
	set(value):
		musica = value
		set_volume("music", musica)
		volume_changed.emit()

@export_range(0.0, 100.0, 1) var efeito: float = 100:
	set(value):
		efeito = value
		set_volume("effects", efeito)
		volume_changed.emit()

var configures: DataConf = DataConf.new()

signal volume_changed

func _ready() -> void:
	Carregar_Arquivo()
	set_volume("music", musica)
	set_volume("effects", efeito)

func Carregar_Arquivo() -> DataConf:
	if not ResourceLoader.exists(GLOBAl_PATH):
		return DataConf.new()
	
	var conf = ResourceLoader.load(GLOBAl_PATH)
	return conf

func Salvar_Arquivo() -> void:
	var err := ResourceSaver.save(configures, GLOBAl_PATH)
	if err != OK:
		push_error("❌ Falha ao salvar. Código de erro: %s" % [err])
	else:
		print("💾 Dados salvos")

func Hello_OS() -> void:
	match OS.get_name():
		"Windows":
			print("Welcome to Windows!")
		"macOS":
			print("Welcome to macOS!")
		"Linux", "FreeBSD", "NetBSD", "OpenBSD", "BSD":
			print("Welcome to Linux/BSD!")
		"Android":
			print("Welcome to Android!")
		"iOS":
			print("Welcome to iOS!")
		"Web":
			print("Welcome to the Web!")

func Tocar_Musica(caminho: String = "", volume: float = 100.0, loop: bool = true, atraso: float = 0.0, canal: int = 1, tipo: String = "music") -> void:
	if audios.has(canal):
		audios[canal].tocar(caminho, volume, loop, atraso, tipo)
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
	
	emit_signal("volume_changed")

func play_transition(anim: String) -> float:
	animation_global.play(anim)
	return animation_global.get_animation(anim).length

func test_node(node: Node2D) -> void:
	var pos: Vector2 = DataUtilities.world_to_screen(node)
	$Sprite2D.global_position = pos
