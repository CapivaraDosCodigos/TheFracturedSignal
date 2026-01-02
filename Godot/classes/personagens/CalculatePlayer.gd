class_name CalculatePlayer
extends Resource

@export_group("life")
@export var base_life: int = 100
@export var growth_rate_life: float = 1.15

@export_group("defense")
@export var base_defense: int = 10
@export var growth_rate_defense: float = 1.15

@export_group("resource")
@export var base_resource: int = 5
@export var growth_rate_resource: float = 1.15

@export_group("attack")
@export var base_attack: int = 5
@export var growth_rate_attack: float = 1.15

@export_group("sp")
@export var base_sp: int = 250
@export var multiplier_sp: float = 1.5

func signal_calculator(base: int, growth_rate: float, level: int, extra: int) -> int:
	return int(base * pow(growth_rate, level - 1)) + extra

func life_calculator(level: int, extra: int) -> int:
	return int(((base_life * pow(growth_rate_life, level - 1)) + extra) / 10) * 10

func defense_calculator(level: int, extra: int) -> int:
	return signal_calculator(base_defense, growth_rate_defense, level, extra)

func resource_calculator(level: int, extra: int) -> int:
	return signal_calculator(base_resource, growth_rate_resource, level, extra)

func attack_calculator(level: int, extra: int) -> int:
	return signal_calculator(base_attack, growth_rate_attack, level, extra)

func calcular_level(expi: int) -> int:
	var level = 1
	var exp_need = base_sp
	
	while expi >= exp_need:
		expi -= exp_need
		level += 1
		exp_need = int(exp_need * multiplier_sp)
	
	return level

func calcular_max_damage(damage: int, extra: int, strength: int, multiple: float) -> int:
	return int((damage + extra) * (1.0 + strength / 10.0) * multiple)

func calcular_min_damage(maxdamage: int, damage: int, extra: int) -> int:
	var diff = maxdamage - (damage + extra)
	if diff <= 0:
		return diff
	return 0

func filtrar_comsumivel(array_original: Array[DataItem]) -> Array[DataItem]:
	var arr: Array[DataItem] = []
	for i in array_original:
		if i is ItemConsumivel:
			arr.append(i)
	return arr
