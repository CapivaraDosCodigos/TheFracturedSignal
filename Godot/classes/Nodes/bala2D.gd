extends CharacterBody2D
class_name Bala2D

@export var dano: int = 1
@export var speed: float = 40.0
@export var diretion: Vector2 = Vector2.ZERO

func _physics_process(_delta: float) -> void:
	if !visible:
		queue_free()
		
	#if Manager.current_status != Manager.GameState.BATTLE:
		#queue_free()
	
	if Manager.current_status == Manager.GameState.BATTLE:
		velocity = diretion * speed
		
	move_and_slide()
	
func _on_visible_screen_exited() -> void:
	queue_free()
