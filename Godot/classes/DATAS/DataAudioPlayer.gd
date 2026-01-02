extends Resource
class_name DataAudioPlayer

@export_file("*.*ogg", "*.*mp3", "*.*wav") var caminho: String = ""
@export_enum("music", "effects") var tipo: String = "music"
@export_range(0.0, 100.0) var volume: float = 100.0
@export var loop: bool = false
@export var atraso: float = 0.0
@export var pitchRandom: bool = false

func _init(_caminho: String = "", _tipo: String = "music",
	_volume: float = 100.0, _loop: bool = true,
	_atraso: float = 0.0, _pitchRandom: bool = false) -> void:
	
	caminho = _caminho
	tipo = _tipo
	volume = _volume
	loop = _loop
	atraso = _atraso
	pitchRandom = _pitchRandom
