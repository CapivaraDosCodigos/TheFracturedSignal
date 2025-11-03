class_name PlayerBase2D extends AnimatedSprite2D

@export var player: String
@export var fallen: bool = false
@export var size_marker: float = 20

var rootbatalha: SimplesBatalha2D
var id: int = 0

func _process(_delta: float) -> void:
	if Manager.PlayersAtuais[player].Life <= 0:
		_dead()
	
	if Manager.PlayersAtuais[player].Life > 0:
		fallen = false
		Manager.PlayersAtuais[player].fallen = false

func _ready() -> void:
	animation_finished.connect(_on_animation_finished)

func _dead() -> void:
	fallen = true
	Manager.PlayersAtuais[player].fallen = true

func act_in_player(_act: String) -> void:
	#print(nome + " com preguisa")
	pass

func _on_animation_finished() -> void:
	pass

func _to_string() -> String:
	return player
