extends PanelContainer
class_name ActMenu

@export var submenu_inimigos: BatalhaSubmenuEnemies

@onready var list: ItemList = $MarginContainer/HBoxContainer/ItemList
@onready var item_label: RichTextLabel = $MarginContainer/HBoxContainer/ItemLabel

var selecting: bool = false
var current_index: int = 0

var last_index: int = -1
var last_act: String = ""
var last_inimigo: int = -1

var actLocais: Array[String] = []
var inimigoLocais: EnemiesBase2D

func _ready() -> void:
	visible = false
	set_process_unhandled_input(false)

func _unhandled_input(event: InputEvent) -> void:
	if not selecting:
		return

	if list.item_count == 0:
		return

	if event.is_action_pressed("Up"):
		Manager.tocar_musica(PathsMusic.MODERN_3, 2)
		current_index = max(current_index - 1, 0)
		_focus_item()

	elif event.is_action_pressed("Down"):
		Manager.tocar_musica(PathsMusic.MODERN_3, 2)

		current_index = min(current_index + 1, list.item_count - 1)
		_focus_item()

	elif event.is_action_pressed("confirm"):
		Manager.tocar_musica(PathsMusic.MODERN_9, 3)
		last_index = current_index
		last_act = actLocais[last_index]
		end()
		
	elif event.is_action_pressed("cancel"):
		Manager.tocar_musica(PathsMusic.CANCEL, 3)
		_reset_result()
		end()

func _reset_result() -> void:
	last_index = -1
	last_act = ""
	last_inimigo = -1

func _focus_item() -> void:
	list.select(current_index, true)
	list.ensure_current_is_visible()
	#var exe: Executable = ExesLocais[current_index]
	#item_label.text = exe.descricao

func atualizar_itemlist(acts: Array[String]) -> void:
	list.clear()
	for act in acts:
		list.add_item(act)

func get_act_inimigo() -> Dictionary:
	selecting = true
	current_index = 0
	_reset_result()
	
	set_process_unhandled_input(false)
	last_inimigo = await submenu_inimigos.get_inimigo()
	
	actLocais = submenu_inimigos.get_inimigo_for_int(last_inimigo).acts
	atualizar_itemlist(actLocais)
	_focus_item()

	visible = true
	set_process_unhandled_input(true)

	if list.item_count > 0:
		list.select(0, true)

	while selecting:
		await get_tree().process_frame

	set_process_unhandled_input(false)
	visible = false

	return { "index": last_index, "act": last_act, "inimigo": last_inimigo }

func end() -> void:
	selecting = false
	visible = false
