@icon("res://Resources/texturas/PlayerPng.tres")
class_name PlayerData
extends Resource

enum Souls { Empty = 1, Hope = 2, Ambition = 3}

@export var Life: int = 100:
	set(value):
		Life = value
		if Life < -999:
			Life = -999
@export var baseLife: int = 100
@export var baseAttack: int = 1
@export var baseDefense: int = 1

@export_category("Informaçoes")
@export var InventoryPlayer: Inventory
@export var Classe: ClasseData
@export var Soul: Souls = Souls.Empty
@export var Bitcoin: int = 0
@export_range(0, 10, 1) var Disquetes: int = 0

@export_subgroup("Array's")
@export var effects: Array[Effect] = []
@export_enum("ATK", "ITM", "EXE", "DEF", "ACT") var blocked_actions: Array[String] = []
@export_enum("ATK", "ITM", "EXE", "DEF", "ACT") var hidden_actions: Array[String] = []

@export_subgroup("Exes", "EXE")
@export var EXE_Inventory_Executables: Array[Executable] = []
@export var EXE_slot_1: Executable
@export var EXE_slot_2: Executable
@export var EXE_slot_3: Executable
@export var EXE_slot_4: Executable

@export_group("PackedScenes")
@export_file("*.*tscn") var PlayerBatalhaPath: String = ""
@export_file("*.*tscn") var ObjectPlayerPath: String = ""

@export_category("Visual")
@export_placeholder("Character") var Nome: String = ""
@export var Icone: Texture

var resistance_mult: float = 1.0
var force_mult: float = 1.0
var maxDamage: int = 1:
	get = _get_maxDamage
var minDamage: int = 1:
	get = _get_minDamage
var maxLife: int = 1:
	get = _get_maxLife
var defense: int = 1:
	get = _get_defense
var attack: int = 1:
	get = _get_attack

var skip_turn: bool = false
var isDefesa: bool = false
var fallen: bool = false

func _to_string() -> String:
	return Nome

func apply_damage(dano: int, ignore: bool = false) -> void:
	if ignore:
		Life -= dano
		return

	var defesa_final: float = defense * resistance_mult
	var reducao = log(defesa_final + 1.0) / 10.0

	var dano_final = int(dano * (1.0 - reducao))

	if isDefesa:
		dano_final = int(dano_final * 0.5)

	Life -= dano_final

func apply_effects() -> void:
	for effect in effects:
		effect.sofrer(self)

func reset() -> void:
	Life = maxLife

func get_Executables() -> Array[Executable]:
	var Exes: Array[Executable] = [EXE_slot_1, EXE_slot_2, EXE_slot_3, EXE_slot_4]
	return Exes.filter(func(value): return value != null)

func _get_maxLife() -> int:
	if not Classe:
		push_error("erro, sem classe")
		return 0
	
	maxLife = baseLife + Classe.get_life(Disquetes)
	return maxLife

func _get_defense() -> int:
	if not Classe:
		push_error("erro, sem classe")
		return 0
	
	defense = baseDefense + Classe.get_defense()
	return defense

func _get_attack() -> int:
	if not Classe:
		push_error("erro, sem classe")
		return 0
	
	attack = baseAttack + Classe.get_attack()
	return attack

func _get_maxDamage() -> int:
	if not Classe:
		push_error("erro, sem classe")
		return 0
	
	maxDamage = Classe.get_damage() + attack
	return int(maxDamage * force_mult)

func _get_minDamage() -> int:
	if not Classe:
		push_error("erro, sem classe")
		return 0
	
	minDamage = int(maxDamage * 0.1)
	return minDamage
