class_name ClassePlayer extends Resource

#region funcs

func _to_string() -> String:
	return self.resource_name

func signal_calculator(base: int, growth_rate: float, level: int, extra: int) -> int:
	return int(base * pow(growth_rate, level -1)) + extra

func calcular_level(_exp: int, base_exp: int, multiplicador: float) -> int:
	var level = 1
	var exp_necessaria = base_exp
	while _exp >= exp_necessaria:
		_exp -= exp_necessaria
		level += 1
		exp_necessaria = int(exp_necessaria * multiplicador)
	return level

func filtrar_comsumivel(array_original: Array[DataItem]) -> Array[DataItem]:
	var array_filtrado: Array[DataItem] = []

	for i in range(array_original.size()):
		if array_original[i] is ItemConsumivel:
			array_filtrado.append(array_original[i])

	return array_filtrado

func calcular_max_damage(_damege: int, _extra: int, _strength: int) -> int:
	return int((_damege + _extra)  * (1.0 + _strength / 10.0))

func calcular_min_damage(_maxdamege: int, _damege: int, _extra: int) -> int:
	if _maxdamege - (_damege + _extra) <= 0:
		return _maxdamege - (_damege + _extra)
	return 0

#endregion
