extends ClasseData
class_name CirurgiaoClasse

@export var Arma: ItemArma
@export var Armadura: ItemArmadura 

func get_life(dis: int = 0) -> int:
	var life: int = 0
	
	if Arma:
		life += Arma.extra_life
	
	if Armadura:
		life += Armadura.extra_life
	
	life += _calcularLife(dis)
	return life

func get_damage(_dis: int = 0) -> int:
	var damage: int = 0
	
	if Arma != null:
		damage += Arma.damage
	
	if Armadura != null:
		damage += Armadura.extra_damage
	
	return damage

func get_defense(_dis: int = 0) -> int:
	var defense: int = 0
	
	if Arma != null:
		defense += Arma.extra_defense
	
	if Armadura != null:
		defense += Armadura.defesa
	
	return defense

func get_attack(_dis: int = 0) -> int:
	var attack: int = 0
	
	if Arma != null:
		attack += Arma.extra_attack
	
	if Armadura != null:
		attack += Armadura.extra_attack
	
	return attack
