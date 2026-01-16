extends SpawnProjeteis

@export var quantidade: int = 1

func spawn(root: Node, time: int) -> void:
	var passo: float = TAU / quantidade

	for i in range(1, int(time / espera)):
		await get_tree().create_timer(espera).timeout
		
		var angulo_base: float = randf_range(0.0, TAU)

		for j in range(quantidade):
			var balaNew: Bala2D = bala.instantiate()
			balaNew.position = makers[0]

			var angulo: float = angulo_base + passo * j
			balaNew.direction = Vector2.from_angle(angulo)

			root.add_child(balaNew)
