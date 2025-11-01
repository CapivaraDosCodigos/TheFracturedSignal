extends PanelContainer
class_name batalha_submenu_enemies

@onready var list: ItemList = $MarginContainer/ItemList
var inimigos: Dictionary[int, EnemiesBase2D] = {}
var current_index: int = 0
var item_bool: bool = false
var last_index: int = -1

func _ready() -> void:
	visible = false
	current_index = 0

func get_inimigo(inimigos_custom: Dictionary[int, EnemiesBase2D]) -> int:
	item_bool = true
	visible = true
	current_index = 0
	
	inimigos = inimigos_custom
	_atualizar_inimigos()

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
	
	if event.is_action_pressed("Right"):
		if list.get_item_count() == 0:
			return
		if current_index < list.get_item_count() - 1:
			current_index += 1
			list.select(current_index, true)
			list.ensure_current_is_visible()
	
	elif event.is_action_pressed("Left"):
		if list.get_item_count() == 0:
			return
		if current_index > 0:
			current_index -= 1
			list.select(current_index, true)
			list.ensure_current_is_visible()
	
	elif event.is_action_pressed("confirm") and list.get_item_count() != 0:
		last_index = inimigos.keys().get(current_index)
		end()
	
	elif event.is_action_pressed("cancel"):
		last_index = -1
		end()

func end() -> void:
	visible = false
	item_bool = false

func _atualizar_inimigos() -> void:
	list.clear()
	for inim: EnemiesBase2D in inimigos.values():
		list.add_item(inim.nome)
