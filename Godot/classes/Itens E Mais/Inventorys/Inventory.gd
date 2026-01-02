@icon("res://Resources/texturas/inventory_png.tres")
class_name Inventory extends Resource

@export var items: Array[DataItem]:
	get = _get_items
@export var limite: int = 15
@export var Bitcoin: int = 25
@export var name: String = "New Inventory"

func _to_string() -> String:
	return name

func _get_items() -> Array[DataItem]:
	items.filter(func(a): return a != null)
	return items

func add_item(item: DataItem) -> void:
	if items.size() + 1 <= limite:
		items.append(item)

func remove_item(index: int) -> void:
	if index >= 0 and index < items.size():
		items.remove_at(index)

func remove_for_item(item: DataItem) -> void:
	if items.has(item):
		items.erase(item)

func remove_item_in_batalha(index: int) -> void:
	var new_items: Array[DataItem] = get_in_items_batalha()
	
	if index >= 0 and index < new_items.size():
		remove_for_item(new_items[index])

func use_item_in_batalha(index: int, player: String) -> void:
	var new_items: Array[DataItem] = get_in_items_batalha()
	
	if index >= 0 and index < new_items.size():
		new_items[index].usar(player)

func get_in_items_batalha() -> Array[DataItem]:
	var get_itens: Array[DataItem] = []
	for item in items:
		if item.inBatalha:
			get_itens.append(item)
	return get_itens
