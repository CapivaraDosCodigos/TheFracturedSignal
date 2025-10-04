class_name PlayerBase2D extends AnimatedSprite2D

@export var player: PlayerData = PlayerData.new()

var rootbatalha: Batalha2D
var id: int = 0

func _process(_delta: float) -> void:
	if player.Life <= 0:
		_dead()

func _ready() -> void:
	animation_finished.connect(_on_animation_finished)

func _dead() -> void:
	pass

func act_in_player(_act: String) -> void:
	#print(nome + " com preguisa")
	pass

func _on_animation_finished() -> void:
	if animation == "dead" and animation == "dead":
		queue_free()

func _to_string() -> String:
	return player.Nome
