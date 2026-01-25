@icon("res://Resources/texturas/armadura.tres")
class_name ItemArmadura extends ItemEquippable

enum Pesos { Leve, Medio, Pesado }

@export var defesa: int = 10
@export var extra_life: int = 0
@export var extra_damage: int = 0
@export var extra_attack: int = 0
@export var peso: Pesos = Pesos.Medio
