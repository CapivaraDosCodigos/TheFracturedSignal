class_name CalculatePlayer extends Resource

static func signal_calculator(base: int, growth_rate: float, level: int, extra: int) -> int:
	return int(base * pow(growth_rate, level -1)) + extra

static func life_calculator(base: int, growth_rate: float, level: int, extra: int) -> int:
	return int(((base * pow(growth_rate, level -1)) + extra) / 10) * 10

static func calcular_level(_exp: int, base_exp: int, multiplicador: float) -> int:
	var level = 1
	var exp_necessaria = base_exp
	while _exp >= exp_necessaria:
		_exp -= exp_necessaria
		level += 1
		exp_necessaria = int((exp_necessaria * multiplicador))
	return level

static func filtrar_comsumivel(array_original: Array[DataItem]) -> Array[DataItem]:
	var array_filtrado: Array[DataItem] = []

	for i in range(array_original.size()):
		if array_original[i] is ItemConsumivel:
			array_filtrado.append(array_original[i])

	return array_filtrado

static func calcular_max_damage(_damege: int, _extra: int, _strength: int) -> int:
	return int((_damege + _extra)  * (1.0 + _strength / 10.0))

static func calcular_min_damage(_maxdamege: int, _damege: int, _extra: int) -> int:
	if _maxdamege - (_damege + _extra) <= 0:
		return _maxdamege - (_damege + _extra)
	return 0
