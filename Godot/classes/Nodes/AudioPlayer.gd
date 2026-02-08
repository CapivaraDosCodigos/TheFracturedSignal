@icon("res://texture/PNG/icon/godot/headphones.svg")
extends AudioStreamPlayer
class_name AudioPlayer

var volume_local: float = 100.0
var tipo_audio: String = "music"
var path_audio: String = ""

func _ready() -> void:
	Global.AllAudios.append(self)
	atualizar_volume()

func atualizar_volume() -> void:
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

func tocar(DataAudio: DataAudioPlayer) -> void:
	stop()

	if DataAudio.caminho == "":
		return
	
	if not ResourceLoader.exists(DataAudio.caminho):
		push_warning("⚠️ Caminho inválido: " + DataAudio.caminho)
		return
	
	var som = load(DataAudio.caminho)
	if som == null or not som is AudioStream:
		push_warning("⚠️ Arquivo não é um AudioStream válido: " + DataAudio.caminho)
		return
	
	som = som.duplicate()
	if "loop" in som:
		som.loop = DataAudio.loop
	
	stream = som
	path_audio = DataAudio.caminho
	volume_local = clamp(DataAudio.volume, 0.0, 100.0)
	pitch_scale = 1.0
	if DataAudio.pitchRandom:
		pitch_scale = randf_range(0.8, 1.2)
	
	tipo_audio = DataAudio.tipo
	
	atualizar_volume()
	
	if DataAudio.atraso > 0.0:
		await get_tree().create_timer(DataAudio.atraso).timeout
	
	play()

func isAudio(Audio: String) -> bool:
	if path_audio == Audio:
		return true
	return false
