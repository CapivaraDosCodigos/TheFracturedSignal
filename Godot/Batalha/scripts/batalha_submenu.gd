extends MarginContainer

@onready var list: ItemList = %ItemList
var current_index: int = 0
var item_bool: bool = false
var last_result: Dictionary = {"texto": null, "index": -1}
var items: Array

func _ready() -> void:
	list.get_v_scroll_bar().visible = false
	list.get_h_scroll_bar().visible = false
	visible = false
	current_index = 0

# Chamado por quem quer abrir o menu: "await itemMenu.itemsIvt()"
func itemsIvt() -> Dictionary:
	item_bool = true
	visible = true
	current_index = 0
	if list.get_item_count() > 0:
		list.select(current_index, true)

	# espera até o jogador confirmar (ou cancelar)
	while item_bool:
		await get_tree().process_frame

	# copia resultado e reseta
	var res := last_result.duplicate()
	last_result = {"texto": null, "index": -1}
	return res

func _unhandled_input(event: InputEvent) -> void:
	if not item_bool:
		return
	
	if event.is_action_pressed("Down"):
		if list.get_item_count() == 0: return
		if current_index < list.get_item_count() - 1:
			current_index += 1
			list.select(current_index, true)
			list.ensure_current_is_visible()

	elif event.is_action_pressed("Up"):
		if list.get_item_count() == 0: return
		if current_index > 0:
			current_index -= 1
			list.select(current_index, true)
			list.ensure_current_is_visible()

	elif event.is_action_pressed("confirm"):
		# define resultado e fecha
		var texto = list.get_item_text(current_index)
		last_result = {"texto": texto, "index": current_index}
		end()

	elif event.is_action_pressed("cancel"):
		# cancela sem resultado (index -1)
		last_result = {"texto": null, "index": -1}
		end()

func end() -> void:
	visible = false
	item_bool = false

func atualizar_itemlist() -> void:
	list.clear()
	for item in Starts.InvData.itens:
		list.add_item(item.nome, item.icone)
