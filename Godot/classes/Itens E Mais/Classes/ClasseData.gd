extends Resource
class_name ClasseData

func get_life(_dis: int = 0) -> int:
	return 0

func get_damage(_dis: int = 0) -> int:
	return 0

func get_defense(_dis: int = 0) -> int:
	return 0

func get_attack(_dis: int = 0) -> int:
	return 0

func _calcularLife(dis: int) -> int:
	if dis <= 0:
		return 0
	
	var total: int = 0
	for i in range(1, dis + 1):
		total += (i * 5) + 15
	return total
