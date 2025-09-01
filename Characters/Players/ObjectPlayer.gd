class_name ObjectPlayer extends CharacterBody2D

@export var speed: float = 70.0

@export_group("Speed", "speed_")
@export var speed_running: float = 1.0
@export var speed_walk: float = 1.5

@export_group("Anim", "anim_")
@export var anim_running: float = 1.0
@export var anim_walk: float = 1.5

@export_group("Nodes")
@export var anim_player: AnimationPlayer
@export var RayChat: RayCast2D

var direction: Vector2 = Vector2.ZERO
var last_facing: String = "Down"
var running: float = 1.0

func signal_physics() -> void:
	Manager.raio = RayChat
	var _is_running := true if Input.is_action_pressed("cancel") else false
	direction = input_direction()
	
	anim_player.speed_scale = speed_running if _is_running else speed_walk
	running = anim_running if _is_running else anim_walk
	
	velocity = direction * speed * running
	move_and_slide()
	update_animation(direction)

func input_direction() -> Vector2:
	return Vector2(
		Input.get_action_strength("Right") - Input.get_action_strength("Left"),
		Input.get_action_strength("Down") - Input.get_action_strength("Up")
	).normalized()

func update_animation(_dir: Vector2) -> void:
	if _dir != Vector2.ZERO:
							# Atualiza direção base
		if abs(_dir.x) > abs(_dir.y):
			last_facing = "Right" if _dir.x > 0 else "Left"
		else:
			last_facing = "Down" if _dir.y > 0 else "Up"
																					
		anim_player.play("w_" + last_facing)
	else:
		anim_player.play("i_" + last_facing)
