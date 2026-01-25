extends CharacterBody2D

@export_subgroup("velocity x")
@export var speed : float = 70.0
@export var max_speed: float = 200.0
@export var acceleration: float = 800.0
@export var friction: float = 300.0
@export var turn_friction: float = 1000.0
@export_subgroup("velocity y")
@export var max_time_to_peak : float = 0.5
@export var junp_height : float = 30.0
@export_subgroup("States")
@export var bar_velocity := 0
@export var max_jumps := 2
@export var price_jump := 50
@export var max_bar := 200

@onready var RayChat := $%RayCast
@onready var anim_player := $Anim
@onready var barLine := %barrel

var jump_count := 0
var barRun := 1.0
var jump_velocity := 1.0
var gravity := 1.0
var fall_gravity := 1.5
var direction := 1
var chouch := false

func _ready() -> void:
	Manager.raio = RayChat
	
	jump_velocity = (junp_height * 2) / max_time_to_peak
	gravity = (junp_height * 2) / pow(max_time_to_peak, 2)
	fall_gravity = gravity * 2
	barLine.max_value = max_bar
	barLine.visible = true

func _physics_process(_delta) -> void:
	if Manager.current_status == Manager.GameState.MAP:
		Zeno_physics(_delta)
	if Manager.current_status == Manager.GameState.DIALOGUE:
		update_animation()
		if not is_on_floor() or velocity.y > 0:
			velocity.y += fall_gravity * _delta
		position = position.snapped(Vector2.ONE)
		move_and_slide()

func Zeno_physics(_delta):
	chouch = true if Input.is_action_pressed("Down") and is_on_floor() else false
	var input_dir = Input.get_axis("Left", "Right")
	direction = sign(input_dir) if input_dir != 0 else 0
	barLine.value = bar_velocity
	barRun = 1.5 if bar_velocity > 20 else 1.0
	$CanvasL/barrel/barrelBAR.text = str(bar_velocity)
		
	if is_on_floor():
		jump_count = 0
	
	if (Input.is_action_just_pressed("Up") or Input.is_action_just_pressed("cancel")):
		if jump_count == 0:
			velocity.y = -jump_velocity
			jump_count += 1
		elif jump_count <= max_jumps and bar_velocity >= price_jump:
			velocity.y = -jump_velocity
			jump_count += 1
			bar_velocity -= price_jump
		
	if velocity.y > 0 or not (Input.is_action_pressed("Up") or Input.is_action_pressed("cancel")):
		velocity.y += fall_gravity * _delta
	else:
		velocity.y += gravity * _delta
		
	if is_on_floor():
		if input_dir != 0 and !chouch:
			var same_direction = sign(velocity.x) == sign(input_dir) or velocity.x == 0
			var accel = acceleration if same_direction else turn_friction
			velocity.x = move_toward(velocity.x, input_dir * (max_speed * barRun), accel * _delta) 
		else:
			velocity.x = move_toward(velocity.x, 0, friction * _delta)
	else:
		if direction:
			velocity.x = move_toward(velocity.x, direction * (max_speed * barRun) / 2, friction)
		else:
			velocity.x = move_toward(velocity.x, 0, friction)
		
	if input_dir != 0:
		$Sprite.scale.x = direction
		
	position = position.snapped(Vector2.ONE)
	move_and_slide()
	update_animation()

func update_animation():
	var state := ""
	if chouch:
		state = "chouch"
		
	elif velocity.y < 0:
		state = "fall"
				
	elif velocity.y > 0:
		state = "jump"
		
	elif abs(velocity.x) > speed and sign(Input.get_axis("Left", "Right")) != sign(velocity.x):
		state = "skid"
		
	elif abs(velocity.x) > speed:
		state = "dash"
		
	elif abs(velocity.x) > 10:
		state = "walk"
																																														
	else:
		state = "idle"
		
	if anim_player.current_animation != state:
		anim_player.play(state)

func _on_timer_timeout() -> void:
	if bar_velocity < max_bar:
		bar_velocity += 2 if abs(velocity.x) < speed else 1
	if bar_velocity > max_bar:
		bar_velocity = max_bar
		
	if abs(velocity.x) > speed * 1.5 and bar_velocity > 4 and is_on_floor():
		bar_velocity -= 4
