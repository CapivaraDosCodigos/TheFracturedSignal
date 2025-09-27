@icon("res://texture/folderTres/texturas/inventory_png.tres")
class_name Inventory extends Resource

@export var items: Array[DataItem]:
	set = _set_items,
	get = _get_items
@export var limite: int = 15:
	set = _set_limite 
@export var name: String = "New Inventory"

func _init(_items: Array[DataItem] = [], _limite: int = 15, _name: String = "New Inventory") -> void:
	items = _items
	limite = _limite
	name = _name
	_atualisar_espaço()

func _to_string() -> String:
	return name

func _atualisar_espaço() -> void:
	items.resize(limite)

func _is_slot_valid(slot: int) -> bool:
	if slot < 0 or slot >= limite:
		return false
	return true

func _set_items(itemsArray: Array[DataItem]) -> void:
	items = itemsArray
	_atualisar_espaço()

func _get_items() -> Array[DataItem]:
	return items

func _set_limite(limites: int) -> void:
	limite = limites
	_atualisar_espaço()

func get_free_slot() -> int:
	for i in range(limite):
		if items[i] == null:
			return i
	return -1

func add_item(item: DataItem, slot: int = -1) -> void:
	if slot == -1:
		slot = get_free_slot()
		if slot == -1:
			return
	if not _is_slot_valid(slot): 
		return
	if items[slot] == null:
		items[slot] = item
	_atualisar_espaço()

func set_item(item: DataItem, slot: int) -> void:
	if not _is_slot_valid(slot): 
		return
	items[slot] = item
	_atualisar_espaço()

func remove_item(slot: int) -> void:
	if not _is_slot_valid(slot): 
		return
	items[slot] = null
	_atualisar_espaço()

func remove_for_item(item: DataItem) -> void:
	if item == null:
		return
	
	for iten in range(limite):
		if items[iten] == item:
			items[iten] = null
			_atualisar_espaço()
			return

func remove_item_in_batalha(index: int) -> void:
	var new_items: Array[DataItem] = get_in_items_batalha()
	
	if index >= 0 and index < new_items.size():
		remove_for_item(new_items[index])

func get_in_items_batalha() -> Array[DataItem]:
	var get_itens: Array[DataItem] = []
	for item in items:
		if item != null and item.inbatalha:
			get_itens.append(item)
	return get_itens
