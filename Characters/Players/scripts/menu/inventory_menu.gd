extends SubMenuBase

@onready var lista: ItemList = %ItemList
var current_index: int = 0

func _on_opened() -> void:
	_atualizar_itemlist()
	
	if lista.get_item_count() > 0:
		current_index = clamp(current_index, 0, lista.get_item_count() - 1)
		lista.select(current_index)

func _unhandled_input(event: InputEvent) -> void:
	if not ativo:
		return
	
	if lista.get_item_count() == 0:
		return
	
	if event.is_action_pressed("Right"):
		if current_index < lista.get_item_count() - 1:
			current_index = (current_index + 1) % lista.get_item_count()
			lista.select(current_index)

	elif event.is_action_pressed("Left"):
		if current_index > 0:
			current_index = (current_index - 1 + lista.get_item_count()) % lista.get_item_count()
			lista.select(current_index)

	elif event.is_action_pressed("Up"):
		if current_index - 3 >= 0:
			current_index -= 3
			lista.select(current_index)

	elif event.is_action_pressed("Down"):
		if current_index + 3 < lista.get_item_count():
			current_index += 3
			lista.select(current_index)

	elif event.is_action_pressed("confirm"):
		if lista.get_item_count() > 0:
			confirmar(current_index)
			_atualizar_itemlist()

func _atualizar_itemlist():
	var items = Manager.get_Inventory().items
	lista.clear()

	for item in items:
		if item != null:
			lista.add_item(item.nome, item.icone)

	if current_index >= lista.get_item_count():
		current_index = max(0, lista.get_item_count() - 1)

func confirmar(_valor: Variant) -> void:
	var item_usado = Manager.get_Inventory().items[current_index]
	Manager.PlayersAtuais[Manager.CurrentPlayerString].InventoryPlayer.remove_for_item(item_usado)
	print("[InventoryMenu] Item confirmado:", item_usado)
