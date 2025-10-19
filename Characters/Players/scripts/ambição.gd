extends CharacterBody2D

@export var speed: float = 150.0
@export var maker: Marker2D

var direction: Vector2 = Vector2.ZERO

func _physics_process(_delta: float) -> void:
	if Manager.current_status == Manager.GameState.BATTLE:
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
	
	var keys = Manager.PlayersAtuais.keys()
	for idx in range(keys.size()):
		var key = keys[idx]
		Manager.PlayersAtuais[key].apply_damage(body.dano)
		print(Manager.PlayersAtuais[key].Life)
		
	body.queue_free()
