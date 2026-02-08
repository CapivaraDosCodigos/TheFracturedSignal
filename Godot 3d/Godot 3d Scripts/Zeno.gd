@icon("res://texturas/zeninho.tres")
extends CharacterBody2D
class_name Zeno_X

@onready var Post_Process = %PostProcess as PostProcess
@onready var animShot = $Animshot as AnimationPlayer
@onready var point = $sprite/point_gun as Marker2D

@export var junp_height := 55
@export var max_time_to_peak := 0.5
@export var dash_duration: float = 0.2
@export var dash_cooldown: float = 0.5

@export var max_speed: float = 400.0
@export var acceleration: float = 800.0
@export var friction: float = 300.0
@export var turn_friction: float = 1000.0

var dash_speed: float
var is_dashing: bool = false
var is_squat: bool = false
var dash_direction: Vector2 = Vector2.ZERO
var can_dash: bool = true

var Gun := preload("res://Itens/pistola.tscn")
var arma : Sprite2D

var ghost_scene := preload("res://personagens/players e npcs/sumiu.tscn")
var ghost_scene2 := preload("res://personagens/players e npcs/sumiu2.tscn")

var ghost_timer := 0.0
var ghost_interval := 0.03

var is_hurted := false
var jump_velocity := 1
var gravity := 1
var fall_gravity := 1.5
var facing_dir := Vector2.RIGHT
var direction
var shoot = true

func _ready() -> void:
	create_gun()
	Global.POS_PROCESS = Post_Process
	dash_speed = max_speed * 2.5
	jump_velocity = (junp_height * 2) / max_time_to_peak
	gravity = (junp_height * 2) / pow(max_time_to_peak, 2)
	fall_gravity = gravity * 2

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if abs(velocity.x) > 0.1:
		facing_dir = Vector2.RIGHT if velocity.x > 0 else Vector2.LEFT
		
	if Global.current_mode == Global.GameStyle.PLATFORM:
		Platform_2d(delta)
		if shoot:
			_set_stateShot()
			
	if arma != null:
		arma.global_position = point.global_position
								# Atualiza a direção da arma
		if not Input.is_action_pressed("blocked shot"):
			atualizar_direcao_arma()
		
																																
	if is_dashing:
		ghost_timer -= delta
		if ghost_timer <= 0:
			spawn_dash_ghost()
			ghost_timer = ghost_interval
	
	
func Platform_2d(delta: float):
	if not is_on_floor():
		velocity.x = 0
						# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = -jump_velocity
																							
	if velocity.y > 0 or not Input.is_action_pressed("jump"):
		velocity.y += fall_gravity * delta
	else:
		velocity.y += gravity * delta
																														# As good practice, you should replace UI actions with custom gameplay actions.
	#direction = Input.get_axis("move left", "move right")
	#if direction and !is_dashing:
		#velocity.x = lerp(velocity.x, direction * SPEED, 0.5)
		#$sprite.scale.x = direction
	#else:
		#velocity.x = move_toward(velocity.x, 0, SPEED)

	var input_dir = Input.get_axis("move left", "move right")
	direction = sign(input_dir) if input_dir != 0 else 0
																								
	if Input.is_action_just_pressed("dash") and can_dash:
		platform_2d_dash($sprite.scale.x)
		
	if Input.is_action_pressed("move down") and velocity.x == 0 and velocity.y >= 0:
		is_squat = true
	else:
		is_squat = false
				
	if is_on_floor() and !is_squat:
		if input_dir != 0 and !is_dashing and !is_squat:
			var same_direction = sign(velocity.x) == sign(input_dir) or velocity.x == 0
			var accel = acceleration if same_direction else turn_friction
			velocity.x = move_toward(velocity.x, input_dir * max_speed, accel * delta)
		else:
			velocity.x = move_toward(velocity.x, 0, friction * delta)
	else:
		if direction and !is_dashing and !is_squat:
			velocity.x = move_toward(velocity.x, direction * max_speed / 2, friction)
		else:
			velocity.x = move_toward(velocity.x, 0, friction)
		
	if input_dir != 0 and !is_dashing:
		$sprite.scale.x = direction
														
		
	move_and_slide()
	
	if global_position.y > 700:
		is_hurted = true
		
func _set_stateShot():
		
	var state := ""
				# 1. Hurt tem prioridade máxima
	if is_hurted:
		state = "hurt"
		Global.cfg.Glitch = true
		await get_tree().create_timer(0.7).timeout
		Global.cfg.Glitch = false
		Global.rest_game()
																							
																								# 2. Pular - Pressionando botão e subindo
	elif Input.is_action_pressed("jump") and velocity.y < 0:
		state = "subir"
															
												# 3. Subir - só subindo, mas não segurando o botão
	elif velocity.y < 0:
		state = "descer"
																																																														
																																																															# 4. Descer
	elif velocity.y > 0:
		state = "subir"
	
	elif is_squat:
		state = "agachado"
		
								
	elif abs(velocity.x) > 100 and sign(Input.get_axis("move left", "move right")) != sign(velocity.x) and not is_dashing:
		state = "freio"
																																
																																	# 6. Correndo
	elif abs(velocity.x) > 10:
		state = "run"
																																										
	else:
		state = "idle"
																																																									
	if animShot.current_animation != state:
		animShot.play(state)
