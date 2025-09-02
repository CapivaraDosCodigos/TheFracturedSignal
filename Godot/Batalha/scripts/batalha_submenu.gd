extends MarginContainer

@onready var list: ItemList = %ItemList
var current_index: int = 0
var item_bool: bool = false

signal item_confirmado(texto: String, index: int)

func _ready() -> void:
	list.get_v_scroll_bar().visible = false
	list.get_h_scroll_bar().visible = false

func itemsIvt() -> Dictionary:
	item_bool = true
	visible = true
	current_index = 0
	if list.get_item_count() > 0:
		list.select(current_index, true)

	# Espera até o jogador confirmar
	var result = await self.item_confirmado
	return {"texto": result[0], "index": result[1]}

func _unhandled_input(event: InputEvent) -> void:
	if not item_bool:
		return

	if event.is_action_pressed("Down"):
		if not current_index == list.get_item_count() - 1:
			current_index = (current_index + 1) % list.get_item_count()
			list.select(current_index, true)
			list.ensure_current_is_visible()

	elif event.is_action_pressed("Up"):
		if not current_index == 0:
			current_index = (current_index - 1 + list.get_item_count()) % list.get_item_count()
			list.select(current_index, true)
			list.ensure_current_is_visible()

	elif event.is_action_pressed("confirm"):
		var texto = list.get_item_text(current_index)
		print("Confirmado:", texto)
		emit_signal("item_confirmado", texto, current_index)
		cancel()

func cancel() -> void:
	visible = false
	item_bool = false
