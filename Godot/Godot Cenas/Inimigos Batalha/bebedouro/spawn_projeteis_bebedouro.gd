extends SpawnProjeteis

func spawn(root: Node, time: int) -> void:
	for i in range(1, int(time / espera)):
		await get_tree().create_timer(espera).timeout
		var balanew: Bala2D = balas[0].instantiate()
		var balanew2: Bala2D = balas[0].instantiate()
		var positiontest: Vector2 = makers.pick_random()
		var test: Array[Vector2] = makers.duplicate()
		test.erase(positiontest)
		balanew.position = positiontest
		balanew2.position = test.pick_random()
		root.add_child(balanew)
		root.add_child(balanew2)
