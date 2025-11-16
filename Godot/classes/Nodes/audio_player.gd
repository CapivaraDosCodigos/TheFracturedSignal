extends AudioStreamPlayer
class_name AudioPlayer

var volume_local: float = 100.0

var tipo_audio: String = "music"

func _ready() -> void:
	Global.volume_changed.connect(_atualizar_volume)
	_atualizar_volume()

func _atualizar_volume() -> void:
	var volume_global = _get_volume_global()
	var volume_real = (volume_local / 100.0) * (volume_global / 100.0)
	volume_db = linear_to_db(volume_real)

func _get_volume_global() -> float:
	match tipo_audio:
		"music":
			return clamp(Global.configures.music, 0.0, 100.0)
		"effects":
			return clamp(Global.configures.sound_effects, 0.0, 100.0)
		_:
			push_warning("⚠️ Tipo de volume desconhecido: " + tipo_audio)
			return 100.0

func tocar(caminho: String = "", volume: float = 100.0, loop: bool = false, atraso: float = 0.0, tipo: String = "musica") -> void:
	stop()
	
	if caminho == "":
		return
	
	if not ResourceLoader.exists(caminho):
		push_warning("⚠️ Caminho inválido: " + caminho)
		return
	
	var som = load(caminho)
	if som == null or not som is AudioStream:
		push_warning("⚠️ Arquivo não é um AudioStream válido: " + caminho)
		return
	
	som = som.duplicate()
	if "loop" in som:
		som.loop = loop
	
	stream = som
	volume_local = clamp(volume, 0.0, 100.0)
	tipo_audio = tipo
	
	_atualizar_volume()
	
	if atraso > 0.0:
		await get_tree().create_timer(atraso).timeout
	
	play()
