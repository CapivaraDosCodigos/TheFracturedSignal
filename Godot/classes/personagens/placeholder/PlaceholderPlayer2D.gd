@tool
extends ObjectPlayer2D
class_name ObjectPlayerAnimado2D

@onready var idle: AnimatedSprite2D = $Idle
@onready var walk: AnimatedSprite2D = $Walk
@onready var run: AnimatedSprite2D = $Run

var last_dir_name: String = "Down"

func _ready() -> void:
	super._ready()
	_set_only(idle)

func _player_physics(_delta: float) -> void:
	if no_player:
		return

	can.priority = 10

	if Manager.Menu.menu:
		_update_animation(Vector2.ZERO)
		return

	Manager.raio = RayChat
	Manager.ObjectPlayer = self

	var is_running: bool = Input.is_action_pressed("cancel")
	direction = _input_direction()
	running = speed_running if is_running else speed_walk

	velocity = direction * speed * running
	move_and_slide()

	_update_animation(direction)
	_update_raycast(direction)

	trail.push_front(global_position)
	if trail.size() > trail_length:
		trail.pop_back()

func _follower_physics(_delta: float) -> void:
	if not no_player:
		return

	can.priority = 0

	if leader == null:
		return

	var _is_running: bool = Input.is_action_pressed("cancel")
	running = speed_running if _is_running else speed_walk

	if stopped_by_area \
	or (RayChat.is_colliding() and RayChat.get_collider() == leader) \
	or leader.trail.size() < trail_length:
		velocity = Vector2.ZERO
		_update_animation(Vector2.ZERO)
		_update_raycast(Vector2.ZERO)
		move_and_slide()
		return

	var target_pos = leader.trail.back()
	var dir: Vector2 = (target_pos - global_position).normalized()

	velocity = dir * speed * running
	move_and_slide()

	_update_animation(dir)
	_update_raycast(dir)

	trail.push_front(global_position)
	if trail.size() > trail_length:
		trail.pop_back()

func _dir_name_to_vector(nome: String) -> Vector2:
	match nome:
		"Down": return Vector2(0, 1)
		"Down_Left": return Vector2(-1, 1).normalized()
		"Left": return Vector2(-1, 0)
		"Up_Left": return Vector2(-1, -1).normalized()
		"Up": return Vector2(0, -1)
		"Up_Right": return Vector2(1, -1).normalized()
		"Right": return Vector2(1, 0)
		"Down_Right": return Vector2(1, 1).normalized()
	return Vector2(0, 1)

func _update_animation(dir: Vector2) -> void:
	var dir_name: String = _get_dir_name(dir)

	if dir != Vector2.ZERO:
		last_dir_name = dir_name

	if dir == Vector2.ZERO:
		_play_anim(idle, last_dir_name)
	else:
		if running == speed_running:
			_play_anim(run, dir_name)
		else:
			_play_anim(walk, dir_name)

func _get_dir_name(dir: Vector2) -> String:
	if dir == Vector2.ZERO:
		return last_dir_name

	var x := dir.x
	var y := dir.y

	if abs(x) < 0.4:
		return "Down" if y > 0 else "Up"

	if abs(y) < 0.4:
		return "Right" if x > 0 else "Left"

	if x > 0 and y > 0: return "Down_Right"
	if x < 0 and y > 0: return "Down_Left"
	if x > 0 and y < 0: return "Up_Right"
	if x < 0 and y < 0: return "Up_Left"

	return "Down"

func _play_anim(node: AnimatedSprite2D, anim: String) -> void:
	_set_only(node)
	node.play(anim)

func _set_only(active: AnimatedSprite2D) -> void:
	idle.visible = (active == idle)
	walk.visible = (active == walk)
	run.visible = (active == run)

func _update_raycast(dir: Vector2) -> void:
	if dir == Vector2.ZERO:
		RayChat.rotation_degrees = _dir_name_to_angle(last_dir_name)
	else:
		RayChat.rotation_degrees = _dir_name_to_angle(_get_dir_name(dir))

func _dir_name_to_angle(nome: String) -> float:
	match nome:
		"Down": return 0
		"Down_Left": return 45
		"Left": return 90
		"Up_Left": return 135
		"Up": return 180
		"Up_Right": return 225
		"Right": return 270
		"Down_Right": return 315
	return 0
