extends CharacterBody2D
class_name Bala2D

@export var dano: int = 1
@export var speed: float = 40.0
@export var direction: Vector2 = Vector2.ZERO

func _physics_process(_delta: float) -> void:
	if !visible:
		queue_free()
		
	if Manager.isState("BATTLE"):
		velocity = direction * speed
		move_and_slide()
		
	elif !Manager.isState("BATTLE_MENU"):
		queue_free()

func _on_visible_screen_exited() -> void:
	queue_free()
