extends Node
class_name SpawnProjeteis

@export var bala: PackedScene  
@export var makers: Array[Vector2]
@export var numero_de_balas: int = 1
@export var espera: float = 1.0

func spawn(root: Node, time: int) -> void:
	for i in range(1, int(time / espera)):
		await get_tree().create_timer(espera).timeout
		var balanew: Bala2D = bala.instantiate()
		var balanew2: Bala2D = bala.instantiate()
		var positiontest: Vector2 = makers.pick_random()
		var test: Array[Vector2] = makers.duplicate()
		test.erase(positiontest)
		balanew.position = positiontest
		balanew2.position = test.pick_random()
		root.add_child(balanew)
		root.add_child(balanew2)
