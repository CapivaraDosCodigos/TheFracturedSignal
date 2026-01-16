@icon("res://Resources/texturas/PlayerPng.tres")
class_name PlayerData
extends Resource

const Calculator: CalculatePlayer = preload("res://Godot/classes/personagens/CalculatePlayerGlobal.tres")
enum Souls { Empty = 1, Hope = 2, Ambition = 3}

@export var Exp: int = 0
@export var Life: int = 100:
	set(value):
		Life = value
		if Life < -999:
			Life = -999
@export var Soul: Souls = Souls.Empty

@export_group("Array's")
@export var effects: Array[Effect] = []
@export var blocked_actions: Array[String] = []
@export var hidden_actions: Array[String] = []

@export_group("Visual")
@export var Nome: String = "Player"
@export var Icone: Texture

@export_group("PackedScenes")
@export_file("*.*tscn") var PlayerBatalhaPath: String = ""
@export_file("*.*tscn") var ObjectPlayerPath: String = ""

@export_group("Armazem")
@export var InventoryPlayer: Inventory = Inventory.new()
@export var armorE: ItemArmadura
@export var weaponsE: ItemArma

@export_group("EXEs", "EXE")
@export var EXE_Inventory_Executables: Array[Executable]
@export var EXE_slot_1: Executable
@export var EXE_slot_2: Executable
@export var EXE_slot_3: Executable
@export var EXE_slot_4: Executable

var force_mult: float = 1.0
var resistance_mult: float = 1.0
var maxlife: int = 100
var Lv: int = 1
var attack: int = 1
var defense: int = 1
var resource: int = 1
var maxdamage: int = 1
var mindamage: int = 1

var isDefesa: bool = false
var skip_turn: bool = false
var fallen: bool = false

func _init() -> void:
	if InventoryPlayer == null:
		InventoryPlayer = Inventory.new()

func _to_string() -> String:
	return Nome

func update_properties() -> void:
	Lv = Calculator.calcular_level(Exp)
	
	var extra_life = armorE.extra_life + weaponsE.extra_life
	var extra_defense = armorE.defesa + weaponsE.extra_defense
	var extra_resource = armorE.extra_resource + weaponsE.extra_resource
	var extra_attack = armorE.extra_strength + weaponsE.extra_strength
	
	maxlife = Calculator.life_calculator(Lv, extra_life)
	defense = Calculator.defense_calculator(Lv, extra_defense)
	resource = Calculator.resource_calculator(Lv, extra_resource)
	attack = Calculator.attack_calculator(Lv, extra_attack)
	
	maxdamage = Calculator.calcular_max_damage(weaponsE.damage, armorE.extra_damage, attack, force_mult)
	mindamage = Calculator.calcular_min_damage(maxdamage, weaponsE.damage, armorE.extra_damage)

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
	Life = maxlife

func get_Executables() -> Array[Executable]:
	var Exes: Array[Executable] = [EXE_slot_1, EXE_slot_2, EXE_slot_3, EXE_slot_4]
	return Exes.filter(func(value): return value != null)

func equip_armor(inv: Inventory, slot: int) -> void:
	if not inv._is_slot_valid(slot): return
	var item = inv.items[slot]
	if item == null: return
	if item is ItemArmadura:
		if armorE != null:
			var free_slot = inv.get_free_slot()
			if free_slot != -1:
				inv.set_item(armorE, free_slot)
		armorE = item
		inv.remove_item(slot)

func equip_weapon(inv: Inventory, slot: int) -> void:
	if not inv._is_slot_valid(slot): return
	var item = inv.items[slot]
	if item == null: return
	if item is ItemArma:
		if weaponsE != null:
			var free_slot = inv.get_free_slot()
			if free_slot != -1:
				inv.set_item(weaponsE, free_slot)
		weaponsE = item
		inv.remove_item(slot)

func unequip_armor(inv: Inventory) -> void:
	if armorE == null: return
	var slot = inv.get_free_slot()
	if slot == -1: return
	inv.set_item(armorE, slot)
	armorE = null

func unequip_weapon(inv: Inventory) -> void:
	if weaponsE == null: return
	var slot = inv.get_free_slot()
	if slot == -1: return
	inv.set_item(weaponsE, slot)
	weaponsE = null
