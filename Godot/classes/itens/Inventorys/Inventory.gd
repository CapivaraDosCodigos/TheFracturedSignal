@icon("res://texture/folderTres/texturas/inventory_png.tres")
class_name Inventory extends Resource

@export var itens: Array[DataItem]: set = set_inventory, get = get_inventory
@export var limite: int = 15: set = set_limite
@export var name: String = "New Inventory"

func _init() -> void:
	_atualisar_espaço()

func _atualisar_espaço() -> void:
	itens.resize(limite)

func _is_slot_valid(slot: int) -> bool:
	if slot < 0 or slot >= limite:
		push_error("❌ Slot inválido: %d" % slot)
		return false
	return true

func set_inventory(itensArray: Array[DataItem]) -> void:
	itens = itensArray
	_atualisar_espaço()

func get_inventory() -> Array[DataItem]:
	return itens

func set_limite(limites: int) -> void:
	limite = limites
	_atualisar_espaço()

func add_item(item: DataItem, slot: int = -1) -> void:
	if slot == -1:
		for i in range(limite):
			if itens[i] == null:
				itens[i] = item
				return
	else:
		if not _is_slot_valid(slot): 
			return
		if itens[slot] == null:
			itens[slot] = item
	_atualisar_espaço()

func set_item(item: DataItem, slot: int) -> void:
	if not _is_slot_valid(slot): 
		return
	itens[slot] = item
	_atualisar_espaço()

func remove_item(slot: int) -> void:
	if not _is_slot_valid(slot): 
		return
	itens[slot] = null
	_atualisar_espaço()
