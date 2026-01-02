extends Resource
class_name DataBatalha

@export var inimigos: Array[PackedScene]
@export_file("*.*dialogue") var dialogo: String
@export var start_dialogo: String
@export var DataAudio: DataAudioPlayer
var id: String = ""

var dungeons2D: Dungeons2D

func _to_string() -> String:
	return start_dialogo

#func gets() -> Dictionary:
	#return {"inimigos": inimigos,
	#"dialogo": dialogo,
	#"start_dialogo": start_dialogo,
	#"caminho": caminho,
	#"volume": volume,
	#"loop": loop,
	#"atraso": atraso}

#func _init(_inimigosB: Array[EnemiesBase], _dialogo: String, _start_dialogo: String, _caminho: String, _volume: float = 100.0, _loop: bool = true, _atraso: float = 0.5) -> void:
	#inimigosB = _inimigosB
	#dialogo = _dialogo
	#start_dialogo = _start_dialogo
	#caminho = _caminho
	#volume = _volume
	#loop = _loop
	#atraso = _atraso
