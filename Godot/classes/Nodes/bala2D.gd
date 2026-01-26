extends CharacterBody2D
class_name Bala2D

@export var dano: int = 1
@export var speed: float = 40.0
@export var direction: Vector2 = Vector2.ZERO

var alma: AlmaBody2D

func _ready() -> void:
	if Manager.CurrentBatalha.battle_arena.ambicao:
		alma = Manager.CurrentBatalha.battle_arena.ambicao

func _physics_process(_delta: float) -> void:
	if !visible:
		queue_free()
		
	if Manager.isState("BATTLE"):
		if global_position.distance_to(alma.global_position) <= 10.0:
			alma._apply_damage(self)
		
		velocity = direction * speed
		move_and_slide()
		
	elif !Manager.isState("BATTLE_MENU"):
		queue_free()

func _on_visible_screen_exited() -> void:
	queue_free()
