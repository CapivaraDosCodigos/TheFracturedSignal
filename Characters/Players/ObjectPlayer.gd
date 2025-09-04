class_name ObjectPlayer
extends CharacterBody2D

@export var speed: float = 70.0
@export var no_player: bool = false # se true, vira "seguidor"

@export_group("Speed", "speed_")
@export var speed_running: float = 1.0
@export var speed_walk: float = 1.5

@export_group("Anim", "anim_")
@export var anim_running: float = 1.0
@export var anim_walk: float = 1.5

@export_group("Nodes")
@export var anim_player: AnimationPlayer
@export var RayChat: RayCast2D

@export var leader: ObjectPlayer # referência ao personagem que vai seguir

var direction: Vector2 = Vector2.ZERO
var last_facing: String = "Down"
var running: float = 1.0

# memória de posições (para followers)
var stopped_by_area: bool = false
var trail: Array[Vector2] = []

@export var trail_length: int = 20 # atraso do seguidor

func player_physics() -> void:
	if no_player:
		return
	
	Manager.raio = RayChat
	var _is_running := not Input.is_action_pressed("cancel")
	direction = _input_direction()
	
	anim_player.speed_scale = speed_running if _is_running else speed_walk
	running = anim_running if _is_running else anim_walk
	
	velocity = direction * speed * running
	move_and_slide()
	update_animation(direction)
	
	# grava trilha
	trail.push_front(global_position)
	if trail.size() > trail_length:
		trail.pop_back()

func follower_physics() -> void:
	if leader == null and not no_player:
		return
		
	var _is_running := not Input.is_action_pressed("cancel")
	anim_player.speed_scale = speed_running if _is_running else speed_walk
	running = anim_running if _is_running else anim_walk
	
	if stopped_by_area:
		velocity = Vector2.ZERO
		update_animation(Vector2.ZERO)
		move_and_slide()
		return
	
	
	
	if RayChat.is_colliding() and RayChat.get_collider() == leader:
		velocity = Vector2.ZERO
		update_animation(Vector2.ZERO)
		move_and_slide()
		return
	
	# garante que o líder tenha trilha
	if leader.trail.size() < trail_length:
		velocity = Vector2.ZERO
		update_animation(Vector2.ZERO)
		move_and_slide()
		return
	
	var target_pos = leader.trail.back()
	var dir = (target_pos - global_position).normalized()
	velocity = dir * speed * running # ligeiramente mais lento que o player
	move_and_slide()
	update_animation(dir)

func update_animation(_dir: Vector2) -> void:
	if _dir != Vector2.ZERO:
		if abs(_dir.x) > abs(_dir.y):
			last_facing = "Right" if _dir.x > 0 else "Left"
		else:
			last_facing = "Down" if _dir.y > 0 else "Up"
		anim_player.play("w_" + last_facing)
	else:
		anim_player.play("i_" + last_facing)

func _input_direction() -> Vector2:
	return Vector2(
		Input.get_action_strength("Right") - Input.get_action_strength("Left"),
		Input.get_action_strength("Down") - Input.get_action_strength("Up")
	).normalized()
	
func _on_area_2d_area_entered(_area: Area2D) -> void:
	stopped_by_area = true

func _on_area_2d_area_exited(_area: Area2D) -> void:
	stopped_by_area = false
