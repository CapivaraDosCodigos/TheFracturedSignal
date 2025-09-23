extends Area2D
class_name AreaCamada2D

@export_range(1, 3) var camada: int = 1

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if not body is ObjectPlayer2D:
		return
	
	body.camada = camada
