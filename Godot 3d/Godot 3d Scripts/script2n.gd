extends CharacterBody2D

var boosted := false
@export var SPEED = 150
@export var JUMP_VELOCITY = -300
@export var dash_velocity = 1400
@onready var anim := $anim as AnimatedSprite2D
@export var orbs_custo = 1
var is_jumping := false
@onready var label = $"control's/coins"
@export var climb_speed: float = 150.0
var colidindo_com_escada: bool = false

var time_dash = true

func apply_boost(boost_vector: Vector2, duration: float) -> void:
	if boosted:
		return
	boosted = true
	velocity = boost_vector
	await get_tree().create_timer(duration).timeout
	velocity = Vector2.ZERO
	boosted = false

func _process(delta):
	label.text = "%d" % Global.coins
	$"control's/orbs".text = "%d" % Global.orbs
		
	if Global.salvar:
		$"control's/pulor".visible = false
		$"control's/direta".visible = false
		$"control's/esquerda".visible = false
		$"control's/ColorRect".visible = true
		$"control's/descer".visible = false
		$"control's/subir".visible = false
	else:
		$"control's/ColorRect".visible = false
		if Global.butt:
			$"control's/pulor".visible = true
			$"control's/direta".visible = true
			$"control's/esquerda".visible = true
			$"control's/descer".visible = true
			$"control's/subir".visible = true
		else:
			$"control's/pulor".visible = false
			$"control's/direta".visible = false
			$"control's/esquerda".visible = false
			$"control's/descer".visible = false
			$"control's/subir".visible = false
					# Seiciar_dash()
			
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		is_jumping = true
	elif is_on_floor():
		is_jumping = false

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
		anim.scale.x = direction
		if not is_jumping:
			if !Global.hurtboxvar:
				anim.play("correr")
			
	else:
		if !Global.hurtboxvar:
			velocity.x = move_toward(velocity.x,0,SPEED)	
			anim.play("Edi")
	
	if Input.is_action_just_pressed("dash"):
		if Global.orbs >= 1:
			Global.dash_ataque = true
			velocity.x = dash_velocity * anim.scale.x
			Global.orbs -= orbs_custo
			await get_tree().create_timer(2.0).timeout
			Global.dash_ataque = false
	
	if is_jumping:
		if !Global.hurtboxvar:
			anim.play("pular")
	
	if Global.hurtboxvar:
		anim.play("hurt")
		velocity.x = 0  # ou seu controle horizontal aqui
	
	if colidindo_com_escada:
		
		if Input.is_action_pressed("ui_up"):
			velocity.y = -climb_speed
						
		elif Input.is_action_pressed("ui_down"):
			velocity.y = climb_speed
	
	move_and_slide()
