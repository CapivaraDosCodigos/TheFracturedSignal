extends PanelContainer
class_name batalha_submenu_itens

@onready var list: ItemList = $MarginContainer/ItemList
var current_index: int = 0
var item_bool: bool = false
var last_index: int = -1

func _ready() -> void:
	visible = false
	current_index = 0

func itemsIvt() -> int:
	item_bool = true
	visible = true
	current_index = 0

	if list.get_item_count() > 0:
		list.select(current_index, true)

	while item_bool:
		await get_tree().process_frame

	var result := last_index
	last_index = -1
	return result

func _unhandled_input(event: InputEvent) -> void:
	if not item_bool:
		return
	
	elif event.is_action_pressed("Up"):
		if list.get_item_count() == 0:
			return
			
		if current_index - 1 >= 0:
			current_index -= 1
			list.select(current_index, true)
			list.ensure_current_is_visible()
	
	elif event.is_action_pressed("Down"):
		if list.get_item_count() == 0:
			return
			
		if current_index + 1 < list.get_item_count():
			current_index += 1
			list.select(current_index, true)
			list.ensure_current_is_visible()
	
	elif event.is_action_pressed("confirm") and list.get_item_count() != 0:
		last_index = current_index
		end()
	
	elif event.is_action_pressed("cancel"):
		last_index = -1
		end()

func end() -> void:
	visible = false
	item_bool = false

func atualizar_itemlist(custom_items: Array = []) -> void:
	list.clear()
	var items = custom_items if not custom_items.is_empty() else Manager.get_Inventory().get_in_items_batalha()
	for item in items:
		list.add_item(item.nome, item.icone)
