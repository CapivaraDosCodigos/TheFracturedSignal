@icon("res://texture/PNG/icon/alma da determinação.png")
extends CharacterBody2D
class_name AlmaBody2D

@onready var invincible_timer: Timer = %invincible_timer

@export var speed: float = 150.0
@export var divide_cp: int = 4
@export_range(0.1, 3.0) var invincible_time: float = 0.5

var direction: Vector2 = Vector2.ZERO
var is_invincible: bool = false
var bullets_processed: Dictionary = {}

func _ready() -> void:
	invincible_timer.one_shot = true
	_reset_color()

func _physics_process(_delta: float) -> void:
	if Manager.isState("BATTLE"):
		_batalha()

func _batalha() -> void:
	direction = Vector2(
		Input.get_action_strength("Right") - Input.get_action_strength("Left"),
		Input.get_action_strength("Down") - Input.get_action_strength("Up")
	).normalized()

	velocity = direction * speed
	move_and_slide()

func _apply_damage(body: Node2D) -> void:
	if not body is Bala2D:
		return

	if is_invincible:
		return

	bullets_processed[body] = true

	_start_invincibility()

	for key in Manager.PlayersAtuais.keys():
		Manager.PlayersAtuais[key].apply_damage(body.dano)
	
	Manager.tocar_musica(PathsMusic.HURT, 3)

	body.queue_free()

func _on_escudo_body_exited(body: Node2D) -> void:
	if not body is Bala2D:
		return

	if is_invincible:
		return

	if bullets_processed.has(body):
		return

	Manager.CurrentBatalha.add_concentration_points(1)
	Manager.tocar_musica(PathsMusic.POWER_UP, 2)
	
	#area.set_cp(int(body.dano / divide_cp))

func _reset_color() -> void:
	if Manager.get_Player().Soul == PlayerData.Souls.Empty:
		modulate = Color(1.0, 1.0, 1.0)
	
	elif Manager.get_Player().Soul == PlayerData.Souls.Hope:
		modulate = Color(0.561, 0.494, 0.816)

func _start_invincibility() -> void:
	is_invincible = true
	modulate = Color(18.892, 18.892, 18.892)
	set_collision_mask_value(1, false)
	set_collision_layer_value(1, false)
	invincible_timer.start(invincible_time)

func _end_invincibility() -> void:
	is_invincible = false
	_reset_color()
	set_collision_mask_value(1, true)
	set_collision_layer_value(1, true)
	bullets_processed.clear()
