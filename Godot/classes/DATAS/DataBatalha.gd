extends Resource
class_name DataBatalha

var inimigosB: Array[EnemiesBase]
var dialogo: String
var start_dialogo: String
var caminho: String
var volume: float = 100.0
var loop: bool = true
var atraso: float = 0.5

func gets() -> Dictionary:
	return {"arrayI": inimigosB,
	"dialogo": dialogo,
	"start_dialogo": start_dialogo,
	"caminho": caminho,
	"volume": volume,
	"loop": loop,
	"atraso": atraso}

#func _init(_inimigosB: Array[EnemiesBase], _dialogo: String, _start_dialogo: String, _caminho: String, _volume: float = 100.0, _loop: bool = true, _atraso: float = 0.5) -> void:
	#inimigosB = _inimigosB
	#dialogo = _dialogo
	#start_dialogo = _start_dialogo
	#caminho = _caminho
	#volume = _volume
	#loop = _loop
	#atraso = _atraso
