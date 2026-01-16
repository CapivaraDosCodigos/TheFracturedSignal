@tool
@icon("res://Resources/texturas/player.tres")
class_name ObjectPlayer2D extends CharacterBody2D

@export var speed: float = 70.0
@export var no_player: bool = false
@export var Nome: String
@export var trail_length: int = 20
@export_range(1, 3, 1) var camada: int = 1:
	set(value):
		camada = value
		_update_camada()
@export_range(1, 8, 1) var local: int = 1:
	set(value):
		local = clamp(value, 1, 8)
		_update_navigation_layer()

@export_group("Velocidades")
@export var speed_running: float = 1.5
@export var speed_walk: float = 1.0

@export_group("Amimaçoes")
@export var anim_running: float = 1.5
@export var anim_walk: float = 1.0

@export_group("Nodes")
@export var anim_player: AnimationPlayer
@export var RayChat: RayCast2D
@export var area: Area2D
@export var agent: NavigationAgent2D
@export var leader: ObjectPlayer2D
@export var can: PhantomCamera2D

var direction: Vector2 = Vector2.ZERO
var last_facing: String = "Down"
var running: float = 1.0

var stopped_by_area: bool = false
var trail: Array[Vector2] = []

func _ready() -> void:
	await get_tree().process_frame
	area.area_entered.connect(_on_area_2d_area_entered)
	area.area_exited.connect(_on_area_2d_area_exited)
	agent.path_desired_distance = 8.0
	agent.target_desired_distance = 8.0
	agent.max_speed = speed
	agent.velocity_computed.connect(_on_velocity_computed)

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	if Manager.isState("MAP"):
		#if Manager.CurrentPlayer != null:
			#no_player = not (Manager.CurrentPlayer.Nome == Nome)
			
		_player_physics(delta)
		_follower_physics(delta)
	
	elif Manager.isState("DIALOGUE"):
		_update_animation(Vector2.ZERO)
		
	elif Manager.isState("MENU"):
		_update_animation(Vector2.ZERO)

func _player_physics(_delta: float) -> void:
	if no_player:
		return
		
	if can.has_method("set_priority"):
		can.priority = 10
	#
	if Manager.isState("MENU"):
		_update_animation(Vector2.ZERO)
		return
	
	Manager.raio = RayChat
	Manager.ObjectPlayer = self
	
	var is_running: bool = Input.is_action_pressed("cancel")
	direction = _input_direction()
	
	running = speed_running if is_running else speed_walk
	anim_player.speed_scale = anim_running if is_running else anim_walk
	
	velocity = direction * speed * running
	move_and_slide()
	_update_animation(direction)
	
	#trail.push_front(global_position)
	#if trail.size() > trail_length:
		#trail.pop_back()

func _follower_physics(_delta: float) -> void:
	if not no_player:
		return
		
	if can.has_method("set_priority"):
		can.priority = 0
	
	if leader == null:
		return
	
	var _is_running: bool = Input.is_action_pressed("cancel")
	anim_player.speed_scale = anim_running if _is_running else anim_walk
	running = speed_running if _is_running else speed_walk
	
	if stopped_by_area:
		velocity = Vector2.ZERO
		_update_animation(Vector2.ZERO)
		move_and_slide()
		return
	
	if RayChat.is_colliding() and RayChat.get_collider() == leader:
		velocity = Vector2.ZERO
		_update_animation(Vector2.ZERO)
		move_and_slide()
		return
	
	#if leader.trail.size() < trail_length:
		#velocity = Vector2.ZERO
		#_update_animation(Vector2.ZERO)
		#move_and_slide()
		#return
	
	#var target_pos = leader.trail.back()
	#var dir = (target_pos - global_position).normalized()
	#velocity = dir * speed * running
	#move_and_slide()
	#_update_animation(dir)
	#
	#trail.push_front(global_position)
	#if trail.size() > trail_length:
		#trail.pop_back()
	
	agent.target_position = leader.global_position

	if agent.is_navigation_finished():
		velocity = Vector2.ZERO
	else:
		var next_path_position = agent.get_next_path_position()
		direction = (next_path_position - global_position).normalized()
		velocity = direction * speed * running

	_update_animation(direction)
		
	move_and_slide()

func _update_navigation_layer() -> void:
	if agent:
		agent.navigation_layers = 1 << (local - 1)

func _on_velocity_computed(_safe_velocity: Vector2) -> void:
	pass

func _update_animation(dir: Vector2) -> void:
	if dir != Vector2.ZERO:
		if abs(dir.x) > abs(dir.y):
			last_facing = "Right" if dir.x > 0 else "Left"
		else:
			last_facing = "Down" if dir.y > 0 else "Up"
		anim_player.play("w_" + last_facing)
	else:
		anim_player.play("i_" + last_facing)

func _input_direction() -> Vector2:
	return Vector2(
		Input.get_action_strength("Right") - Input.get_action_strength("Left"),
		Input.get_action_strength("Down") - Input.get_action_strength("Up")
	).normalized()

func _update_camada() -> void:
	for i in [3, 4, 5]:
		#set_collision_layer_value(i, false)
		set_collision_mask_value(i, false)
	
	if 1 == camada:
		set_collision_mask_value(3, true)
		#set_collision_layer_value(3, true)
		z_index = -2
		#modulate = Color(0, 1, 0)
		
	elif 2 == camada:
		set_collision_mask_value(4, true)
		#set_collision_layer_value(4, true)
		z_index = 1
		#modulate = Color(1, 1, 0)
		
	elif 3 == camada:
		set_collision_mask_value(5, true)
		#set_collision_layer_value(5, true)
		z_index = 3
		#modulate = Color(1, 0, 0)

func _on_area_2d_area_entered(_area: Area2D) -> void:
	if not leader == null:
		if leader.area == _area:
			stopped_by_area = true

func _on_area_2d_area_exited(_area: Area2D) -> void:
	if not leader == null:
		if leader.area == _area:
			stopped_by_area = false
