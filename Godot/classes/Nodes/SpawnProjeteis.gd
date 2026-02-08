extends Node
class_name SpawnProjeteis

@export var balas: Array[PackedScene]
@export var makers: Array[Vector2]
@export var espera: float = 1.0

func spawn(root: Node, time: int) -> void:
	print(root, time)
	pass
