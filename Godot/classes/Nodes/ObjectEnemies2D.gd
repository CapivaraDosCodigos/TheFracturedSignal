@tool
@icon("res://Resources/texturas/makita.tres")
extends CharacterBody2D
class_name ObjectEnemies2D


@export var id: String = "None"
@export var isMove: bool = false
@export var speed: float = 100
@export_range(1, 3, 1) var camada: int = 1:
	set(value):
		camada = value
		_update_camada()
@export_range(1, 8, 1) var local: int = 1:
	set(value):
		local = clamp(value, 1, 8)
		_update_navigation_layer()

@export_group("Nodes")
@export var dungeons2D: Dungeons2D
@export var databatalha: DataBatalha
@export var sprite: AnimatedSprite2D
@export var agent: NavigationAgent2D
@export var marker: Marker2D

var home_position: Vector2 = Vector2.ZERO
var direction: Vector2 = Vector2.ZERO
var dentro_area: bool = false
var visivel: bool = false
var local_body: ObjectPlayer2D

func _ready() -> void:
	if Engine.is_editor_hint():
		_update_navigation_layer()
		return

	if Manager.Extras.EnemiesVistos.has(id):
		queue_free()
		return
		
	_setup_agent()
	home_position = marker.global_position if marker else global_position

func _setup_agent() -> void:
	if not agent:
		return

	agent.path_desired_distance = 8.0
	agent.target_desired_distance = 8.0
	agent.max_speed = speed
	_update_navigation_layer()

func _update_navigation_layer() -> void:
	if agent:
		agent.navigation_layers = 1 << (local - 1)

func _physics_process(_delta: float) -> void:
	if Engine.is_editor_hint() \
	or not isMove \
	or not Manager.isState("MAP"):
		return

	var player: ObjectPlayer2D = Manager.ObjectPlayer
	if not _player_valido(player):
			agent.target_position = home_position
	else:
		agent.target_position = player.global_position

	_process_movement()

func _process_movement() -> void:
	if agent.is_navigation_finished():
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var next_pos: Vector2 = agent.get_next_path_position()
	direction = (next_pos - global_position).normalized()

	var speed_mult: float = 1.0 if dentro_area else 0.5
	velocity = direction * speed * speed_mult

	_update_animation(direction)
	move_and_slide()

func _player_valido(player: ObjectPlayer2D) -> bool:
	return player \
	and player.camada == camada \
	and dentro_area

func _trocar_para_batalha(player_pos: Vector2) -> void:
	databatalha.dungeons2D = dungeons2D
	databatalha.id = id

	var spawn_pos: Vector2 = (player_pos + global_position) * 0.5
	Manager.StartBatalha(databatalha, spawn_pos)
	queue_free()

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

func _update_animation(_dir: Vector2) -> void:
	pass

func _on_area_colisao_body_entered(body: Node2D) -> void:
	if Engine.is_editor_hint():
		return

	if body is ObjectPlayer2D and Manager.isState("MAP"):
		local_body = body
		Manager.change_state("DIALOGUE")
		sprite.play("Attack")

func _on_sprite_animation_finished() -> void:
	if not Engine.is_editor_hint() and local_body:
		call_deferred("_trocar_para_batalha", local_body.global_position)

func _on_area_observacao_body_entered(body: Node2D) -> void:
	if body is ObjectPlayer2D:
		dentro_area = body.camada == camada

func _on_area_observacao_body_exited(body: Node2D) -> void:
	if body is ObjectPlayer2D:
		dentro_area = false
