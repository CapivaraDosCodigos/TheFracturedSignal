extends AudioStreamPlayer
class_name AudioPlayer

var volume_local: float = 100.0; var volume_global_anterior: float = -1.0
var Vmusic: int = 100

func _ready():
	_atualizar_volume()

func _process(_delta: float) -> void:
	if Global.configures == null:
		return
		
	Vmusic = Global.configures.music
	var vol_global = clamp(Vmusic, 0.0, 100.0)
	if vol_global != volume_global_anterior:
		_atualizar_volume()
		volume_global_anterior = vol_global

func tocar_musica(caminho: String = "", volume: float = 100.0, loop: bool = false, atraso: float = 0.0) -> void:
	stop()
	
	if caminho == "":
		return
	
	if not ResourceLoader.exists(caminho):
		push_warning("⚠️ Caminho inválido: " + caminho)
		return
	
	var musica = load(caminho)
	if musica == null or not musica is AudioStream:
		push_warning("⚠️ Arquivo não é um AudioStream válido: " + caminho)
		return
	
	musica = musica.duplicate()
	if "loop" in musica:
		musica.loop = loop
	
	stream = musica
	
	volume_local = clamp(volume, 0.0, 100.0)
	_atualizar_volume()
	
	if atraso > 0.0:
		await get_tree().create_timer(atraso).timeout
	
	play()

func _atualizar_volume():
	var volume_global = clamp(Vmusic, 0.0, 100.0)
	var volume_real = (volume_local / 100.0) * (volume_global / 100.0)
	volume_db = linear_to_db(volume_real)
