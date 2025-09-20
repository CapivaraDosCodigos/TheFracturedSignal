extends CharacterBody2D

@export var speed: float = 150.0

var direction: Vector2 = Vector2.ZERO

func _process(_delta: float) -> void:
	if Manager.current_status == Manager.GameState.BATTLE:
		_batalha()
	else:
		self.visible = false

func _batalha() -> void:
	direction = Vector2(
		Input.get_action_strength("Right") - Input.get_action_strength("Left"),
		Input.get_action_strength("Down") - Input.get_action_strength("Up")
	).normalized()
	
	velocity = direction * speed
	move_and_slide()
	visible = true
