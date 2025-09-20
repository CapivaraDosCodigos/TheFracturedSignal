@icon("res://texture/folderTres/texturas/player_png.tres")
class_name PlayerData extends Resource

@export_group("GamePLayer")
@export var Nome: String = "Player"
@export var Classe: ClassePlayer = ClassePlayer.new()
@export var Anime: SpriteFrames
@export var MaterialP: ShaderMaterial
@export_file("*.*tscn") var objectplayerpath: String

@export_group("PlayerStarts")
@export var Lv: int = 1
@export var Life: int = 30:
	set = _set_life
@export var Bitcoin: int = 25:
	set = _set_bitcoin
@export var Exp: int = 0

@export_group("Dados das Propriedades")
@export_subgroup("life")
@export var base_life: int = 60; @export var growth_rate_life: float = 1.15
@export_subgroup("defense")
@export var base_defense: int = 10; @export var growth_rate_defense: float = 1.15
@export_subgroup("resource")
@export var base_resource: int = 5; @export var growth_rate_resource: float = 1.15
@export_subgroup("attack")
@export var base_attack: int = 5; @export var growth_rate_attack: float = 1.15
@export_subgroup("sp")
@export var base_sp: int = 250; @export var multiplier_sp: float = 1.5

@export_group("Amazenameto")
@export var inventory_pessoal: Inventory
@export var armorE: ItemArmadura
@export var weaponsE: ItemArma

var maxlife: int; var attack: int
var defense: int; var resource: int
var maxdamage: int; var mindamage: int

func update_properties() -> void:
	Lv = Classe.calcular_level(Exp, base_sp, multiplier_sp)
	var extra_life = armorE.extra_life + weaponsE.extra_life
	maxlife = Classe.signal_calculator(base_life, growth_rate_life, Lv, extra_life)
	var extra_defense = armorE.defesa + weaponsE.extra_defense
	defense = Classe.signal_calculator(base_defense, growth_rate_defense, Lv, extra_defense)
	var extra_resource = armorE.extra_resource + weaponsE.extra_resource
	resource = Classe.signal_calculator(base_resource, growth_rate_resource, Lv, extra_resource)
	var extra_attack = armorE.extra_strength + weaponsE.extra_strength
	attack = Classe.signal_calculator(base_attack, growth_rate_attack, Lv, extra_attack)
	maxdamage = Classe.calcular_max_damage(weaponsE.damage, armorE.extra_damage, attack)
	mindamage = Classe.calcular_min_damage(maxdamage, weaponsE.damage, armorE.extra_damage)

func equip_armor(inv: Inventory, slot: int) -> void:
	if not inv._is_slot_valid(slot):
		return
	var item = inv.items[slot]
	if item == null:
		return
	if item is ItemArmadura:
		if armorE != null:
			var free_slot = inv.get_free_slot()
			if free_slot != -1:
				inv.set_item(armorE, free_slot)
		armorE = item
		inv.remove_item(slot)

func equip_weapon(inv: Inventory, slot: int) -> void:
	if not inv._is_slot_valid(slot):
		return
	var item = inv.items[slot]
	if item == null:
		return
	if item is ItemArma:
		if weaponsE != null:
			var free_slot = inv.get_free_slot()
			if free_slot != -1:
				inv.set_item(weaponsE, free_slot)
		weaponsE = item
		inv.remove_item(slot)

func unequip_armor(inv: Inventory) -> void:
	if armorE == null:
		return
	var free_slot = inv.get_free_slot()
	if free_slot == -1:
		return
	inv.set_item(armorE, free_slot)
	armorE = null

func unequip_weapon(inv: Inventory) -> void:
	if weaponsE == null:
		return
	var free_slot = inv.get_free_slot()
	if free_slot == -1:
		return
	inv.set_item(weaponsE, free_slot)
	weaponsE = null

func _set_life(life: int) -> void:
	if not life <= 0:
		Life = life

func _set_bitcoin(bitcoin: int) -> void:
	if not bitcoin <= 0:
		Bitcoin = bitcoin

func _to_string() -> String:
	return Nome
