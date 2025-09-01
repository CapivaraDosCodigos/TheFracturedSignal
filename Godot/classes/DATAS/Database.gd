#ItemDatabase.gd
class_name Database extends Resource

const TOTAL_SLOTS := 3
const SAVE_PATH := "user://save_slot_%d.tres"
const PATH_NOT_SAVE := "user://not_save_slot_%d.tres"
const SAVES_SCENE: Array[PackedScene] = [preload("res://Areais/EP 1/começo.tscn")]

#Armas:
const SIGNAL_WEAPON: ItemArma = preload("res://Godot/classes/itens/armas/Signal_Weapon.tres")
const WEAPONNULL: ItemArma = preload("res://Godot/classes/itens/armas/sem_arma.tres")

#Armaduras:
const OCULOS_SIMPLES: ItemArmadura = preload("res://Godot/classes/itens/armaduras/óculos_simples.tres")
const ARMORNULL: ItemArmadura = preload("res://Godot/classes/itens/armaduras/sem_armadura.tres")

#Consumíveis
const SANDWICH: ItemConsumivel = preload("res://Godot/classes/itens/consumíveis/sandwich.tres")

static func has_item(array: Array, item: DataItem) -> bool:
	for i in array:
		if i == item:
			return true
	return false

static func count_item(array: Array, item: DataItem) -> int:
	var count := 0
	for i in array:
		if i == item:
			count += 1
	return count

static func equip_armor(inv: InventoryData, chararcter: PlayerData, index: int) -> void:
	if index >= 0 and index < inv.armor.size():
		chararcter.armorE = inv.armor[index]
		print(chararcter, " equipou armadura: ", chararcter.armorE.nome)
	else:
		push_error("Índice de armadura inválido!")

static func equip_weapon(inv: InventoryData, chararcter: PlayerData, index: int) -> void:
	if index >= 0 and index < inv.weapons.size():
		chararcter.weaponsE = inv.weapons[index]
		print(chararcter, " equipou arma: ", chararcter.weaponsE.nome)
	else:
		push_error("Índice de arma inválido!")

static func unequip_armor(chararcter: PlayerData) -> void:
	chararcter.armorE = ARMORNULL
	print(chararcter, " removeu a armadura.")

static func unequip_weapon(chararcter: PlayerData) -> void:
	chararcter.weaponsE = WEAPONNULL
	print(chararcter, " removeu a arma.")

static func apply_damage(dano_base: int, defesa: int) -> int:
	var reducao = defesa / (defesa + 1.0)
	var dano_final = int(dano_base * (1.0 - reducao))
	return dano_final
