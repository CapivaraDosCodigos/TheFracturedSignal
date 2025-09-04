extends CharacterBody2D

@export var speed := 150.0

var direction := Vector2.ZERO

		
func _physics_process(_delta: float) -> void:
	if Manager.current_status == Manager.GameState.BATTLE:
		batalha()
	else:
		self.visible = false

func batalha() -> void:
	var input_vector := Vector2(
		Input.get_action_strength("Right") - Input.get_action_strength("Left"),
		Input.get_action_strength("Down") - Input.get_action_strength("Up")
	)
								
	direction = input_vector.normalized()
	velocity = direction * speed
	move_and_slide()
	self.visible = true
	
		
