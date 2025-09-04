extends SubMenuBase

@onready var lista: ItemList = %ItemList
var current_index: int = 0

func _unhandled_input(event: InputEvent) -> void:
	if not ativo:
		return
	
	if event.is_action_pressed("Right"):
		if current_index < lista.get_item_count() - 1:
			current_index = (current_index + 1) % lista.get_item_count()
			lista.select(current_index)

	elif event.is_action_pressed("Left"):
		if current_index > 0:
			current_index = (current_index - 1 + lista.get_item_count()) % lista.get_item_count()
			lista.select(current_index)

	elif event.is_action_pressed("confirm"):
		confirmar(lista.get_item_text(current_index))
		_atualizar_itemlist()

func _on_opened() -> void:
	_atualizar_itemlist()
	lista.select(current_index)
	
func _atualizar_itemlist():
	for i in range(1, 10):
		%ItemList.clear()
		for item in Starts.InvData.itens:
			%ItemList.add_item(item.nome, item.icone)

func confirmar(_valor: Variant) -> void:
	pass
