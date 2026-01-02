extends PanelContainer
class_name BatalhaSubmenuItens

@export var submenu_players: BatalhaSubmenuPlayers

@onready var list: ItemList = $HBoxContainer/ItemList
@onready var item_label: RichTextLabel = $HBoxContainer/VBoxContainer/ItemLabel
@onready var hp_label: RichTextLabel = $HBoxContainer/VBoxContainer/HBoxContainer/HPLabel
@onready var cp_label: RichTextLabel = $HBoxContainer/VBoxContainer/HBoxContainer/CPLabel


var selecting: bool = false
var current_index: int = 0

var last_index: int = -1
var last_player: String = ""

var itemslocais: Array[DataItem] = []

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
		var item: DataItem = itemslocais[current_index]

		if item.need_player:
			set_process_unhandled_input(false)
			last_player = await submenu_players.selecionar()
			end()
		else:
			end()

	elif event.is_action_pressed("cancel"):
		Manager.tocar_musica(PathsMusic.CANCEL, 3)
		_reset_result()
		end()

func _reset_result() -> void:
	last_index = -1
	last_player = ""

func _focus_item() -> void:
	list.select(current_index, true)
	list.ensure_current_is_visible()
	var item: DataItem = itemslocais[current_index]
	item_label.text = item.descricao
	if item is ItemConsumivel:
		if item.cura != 0:
			hp_label.visible = true
			hp_label.text = "+%dHP" % [item.cura]
		else:
			hp_label.visible = false
			
		if item.concentration != 0:
			cp_label.visible = true
			cp_label.text = "+%dCP" % [item.concentration]
		else:
			cp_label.visible = false

func atualizar_itemlist(custom_items: Array = []) -> void:
	list.clear()
	itemslocais = custom_items if not custom_items.is_empty() else Manager.get_Inventory().get_in_items_batalha()
	
	for item in itemslocais:
		list.add_item(item.nome, item.icone)

func itemsIvt() -> Dictionary:
	selecting = true
	current_index = 0
	_focus_item()
	_reset_result()

	visible = true
	set_process_unhandled_input(true)

	if list.item_count > 0:
		list.select(0, true)

	while selecting:
		await get_tree().process_frame

	set_process_unhandled_input(false)
	visible = false

	return { "index": last_index, "player": last_player }

func end() -> void:
	selecting = false
	visible = false
