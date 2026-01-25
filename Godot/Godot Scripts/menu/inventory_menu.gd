extends SubMenuBase

@onready var panel_descricao: PanelContainer = $MarginContainer/HBoxContainer/PanelDescricao
@onready var itemLabel: RichTextLabel = $MarginContainer/HBoxContainer/PanelDescricao/VBoxContainer/RichTextItem
@onready var descricaoLabel: RichTextLabel = $MarginContainer/HBoxContainer/PanelDescricao/VBoxContainer/RichTextDescricao
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
			_focus_item()

	elif event.is_action_pressed("Left"):
		if current_index > 0:
			current_index = (current_index - 1 + lista.get_item_count()) % lista.get_item_count()
			_focus_item()

	elif event.is_action_pressed("Up"):
		if current_index - 3 >= 0:
			current_index -= 3
			_focus_item()

	elif event.is_action_pressed("Down"):
		if current_index + 3 < lista.get_item_count():
			current_index += 3
			_focus_item()

	elif event.is_action_pressed("confirm"):
		if lista.get_item_count() > 0:
			confirmar(current_index)
			_atualizar_itemlist()

func _atualizar_itemlist() -> void:
	var items = Manager.get_Inventory().items
	lista.clear()

	for item in items:
		lista.add_item(item.nome, item.icone)

	if current_index >= lista.get_item_count():
		current_index = max(0, lista.get_item_count() - 1)
	
	_focus_item()

func _focus_item() -> void:
	if lista.get_item_count() == 0:
		itemLabel.text = ""
		descricaoLabel.text = ""
		return

	if current_index < 0 or current_index >= Manager.get_Inventory().items.size():
		return

	var item = Manager.get_Inventory().items[current_index]
	if item == null:
		itemLabel.text = ""
		descricaoLabel.text = ""
		return

	lista.select(current_index)
	itemLabel.text = item.nome
	descricaoLabel.text = item.descricao

func confirmar(_valor: Variant) -> void:
	var items = Manager.get_Inventory().items

	if current_index < 0 or current_index >= items.size():
		return

	var item_usado = items[current_index]
	if item_usado == null:
		return

	Manager.get_Inventory().remove_item(current_index)

	print("[InventoryMenu] Item confirmado:", item_usado)
