extends CharacterBody2D
class_name EnemyFollow

@export var life: int = 100
@export var speed: float = 100.0
@export var target: Node2D
@onready var agent: NavigationAgent2D = $NavigationAgent2D
var direction: Vector2 = Vector2.ZERO

func _ready() -> void:
	agent.path_desired_distance = 8.0
	agent.target_desired_distance = 8.0
	agent.max_speed = speed
	agent.velocity_computed.connect(_on_velocity_computed)

func _physics_process(_delta: float) -> void:
	if target == null:
		return
	if life <= 0:
		queue_free()
	$ProgressBar.value = life
	
	agent.target_position = target.global_position

	if agent.is_navigation_finished():
		velocity = Vector2.ZERO
	else:
		var next_path_position = agent.get_next_path_position()
		direction = (next_path_position - global_position).normalized()
		velocity = direction * speed
	
		if global_position.distance_to(target.global_position) <= 100:
			velocity *= -1

	move_and_slide()

func _on_velocity_computed(_safe_velocity: Vector2) -> void:
	pass
#
#func _on_timer_timeout() -> void:
	#var balinha : bala2D = BALA.instantiate()
	#balinha.position = position
	#balinha.dir = direction
	#balinha.speed += speed
	#add_sibling(balinha)
#
#func _on_area_2d_body_entered(body: Node2D) -> void:
	#if body is bala2D:
		#if body.forInimigo:
			#life -= body.dano
			#body.queue_free()
