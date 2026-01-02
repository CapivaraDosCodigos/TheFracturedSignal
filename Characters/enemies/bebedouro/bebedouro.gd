@icon("res://texture/folderTres/texturas/makita.tres")
extends CharacterBody2D
class_name ObjectEnemies2D

@export var id: String = "None"
@export var dungeons2D: Dungeons2D
@export var databatalha: DataBatalha

func _ready() -> void:
	if Manager.Extras.EnemiesVistos.has(id):
		queue_free()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		call_deferred("_trocar_para_batalha", body.global_position)

func _trocar_para_batalha(pos: Vector2) -> void:
	databatalha.dungeons2D = dungeons2D
	var set_pos = (pos + global_position) / 2
	databatalha.id = id
	Manager.StartBatalha(databatalha, set_pos)
	queue_free()
