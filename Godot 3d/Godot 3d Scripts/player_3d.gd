extends CharacterBody3D


@onready var animated: AnimatedSprite3D = $Animated

const SPEED = 100.0
const JUMP_VELOCITY = 2.5
@export var gravity: float = 10.0

var last_dir: Vector2 = Vector2.DOWN

func _physics_process(delta: float) -> void:
	_handle_move(delta)
	
	_apply_gravity(delta)
	
	move_and_slide()

func _apply_gravity(delta: float):
	if not is_on_floor():
		velocity.y -= gravity * delta

	if Input.is_action_just_pressed("confirm") and is_on_floor():
		velocity.y = JUMP_VELOCITY

func _handle_move(delta: float) -> void:
	var input_dir: Vector2 = Vector2(
		Input.get_action_strength("Right") - Input.get_action_strength("Left"),
		Input.get_action_strength("Down") - Input.get_action_strength("Up")).normalized()
	
	if input_dir == Vector2.ZERO:
		velocity.x = 0
		velocity.z = 0
		_play_idle_anim(last_dir)
		return
	
	#if not is_on_floor():
		#velocity.x = move_toward(velocity.x, 0, 0.5)
		#velocity.z = move_toward(velocity.z, 0, 0.5)
		#play_run_anim(last_dir)
		#return
	
	input_dir = input_dir.normalized()
	
	var move_dir: Vector3 = Vector3(input_dir.x, 0, input_dir.y)
	
	velocity.x = move_dir.x * SPEED * delta
	velocity.z = move_dir.z * SPEED * delta
	
	_update_anim_dir(move_dir)

func _play_idle_anim(dir: Vector2) -> void:
	if abs(dir.x) > abs(dir.y):
		animated.play("idle_right" if dir.x > 0 else "idle_left")
	else:
		animated.play("idle_down" if dir.y > 0 else "idle_up")

func _play_run_anim(dir: Vector2) -> void:
	if abs(dir.x) > abs(dir.y):
		animated.play("run_right" if dir.x > 0 else "run_left")
	else:
		animated.play("run_down" if dir.y > 0 else "run_up")

func _update_anim_dir(world_dir: Vector3) -> void:
	var dir2d: Vector2 = Vector2(world_dir.x, world_dir.z)
	
	if dir2d.length() == 0:
		return
	
	dir2d = dir2d.normalized()
	
	last_dir = dir2d
	
	_play_run_anim(last_dir)
