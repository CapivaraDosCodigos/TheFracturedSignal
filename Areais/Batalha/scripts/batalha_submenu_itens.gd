extends PanelContainer
class_name BatalhaSubmenuItens

@onready var buttaos: Array[InimigoButton] = [ %Player1, %Player2, %Player3 ]
@onready var list: ItemList = $MarginContainer/HBoxContainer/ItemList
@onready var list_player: VBoxContainer = $ListPlayer

var selecting_item := false
var selecting_player := false

var current_index := 0
var current_player_index := 0

var last_index := -1
var last_player := ""

var players_dis: Array[PlayerData] = []
var itemslocais: Array[DataItem] = []

func _ready() -> void:
	visible = false
	list_player.visible = false
	list.visible = true
	set_process_unhandled_input(false)

func _unhandled_input(event: InputEvent) -> void:
	if selecting_item:
		_input_item(event)
	elif selecting_player:
		_input_player(event)

func _input_item(event: InputEvent) -> void:
	if list.item_count == 0:
		return

	if event.is_action_pressed("Up"):
		current_index = max(current_index - 1, 0)
		list.select(current_index, true)
		list.ensure_current_is_visible()

	elif event.is_action_pressed("Down"):
		current_index = min(current_index + 1, list.item_count - 1)
		list.select(current_index, true)
		list.ensure_current_is_visible()

	elif event.is_action_pressed("confirm"):
		last_index = current_index
		var item := itemslocais[current_index]

		if item.need_player:
			selecting_item = false
			selecting_player = true
			list_player.visible = true
			list.visible = false
			current_player_index = 0
			_focus_button()
		else:
			_close()

	elif event.is_action_pressed("cancel"):
		_reset_result()
		_close()

func _input_player(event: InputEvent) -> void:
	if players_dis.is_empty():
		return

	if event.is_action_pressed("Down"):
		current_player_index = (current_player_index + 1) % players_dis.size()
		_focus_button()

	elif event.is_action_pressed("Up"):
		current_player_index = (current_player_index - 1 + players_dis.size()) % players_dis.size()
		_focus_button()

	elif event.is_action_pressed("confirm"):
		last_player = players_dis[current_player_index].Nome
		_close()

	elif event.is_action_pressed("cancel"):
		last_player = ""
		selecting_player = false
		selecting_item = true
		list_player.visible = false
		list.visible = true

func _focus_button() -> void:
	await get_tree().process_frame
	if current_player_index < buttaos.size():
		buttaos[current_player_index].grab_focus()

func _close() -> void:
	selecting_item = false
	selecting_player = false

func _reset_result() -> void:
	last_index = -1
	last_player = ""

func _atualizar_players(players: Array[PlayerData]) -> void:
	for b in buttaos:
		b.visible = false

	for i in range(min(players.size(), buttaos.size())):
		var player := players[i]
		var btn := buttaos[i]

		btn.visible = true
		btn.nome.text = player.Nome
		btn.life.max_value = player.maxlife
		btn.life.value = player.Life

func end() -> void:
	selecting_item = false
	selecting_player = false

	set_process_unhandled_input(false)

	visible = false
	list_player.visible = false
	list.visible = true

func atualizar_itemlist(custom_items: Array = []) -> void:
	list.clear()
	itemslocais = custom_items if not custom_items.is_empty() else Manager.get_Inventory().get_in_items_batalha()

	for item in itemslocais:
		list.add_item(item.nome, item.icone)

func itemsIvt(players: Array[PlayerData]) -> Dictionary:
	players_dis = players
	_atualizar_players(players)
	selecting_item = true
	selecting_player = false

	current_index = 0
	current_player_index = 0
	last_index = -1
	last_player = ""

	visible = true
	list_player.visible = false
	list.visible = true
	set_process_unhandled_input(true)

	if list.item_count > 0:
		list.select(0, true)

	while selecting_item or selecting_player:
		await get_tree().process_frame

	set_process_unhandled_input(false)
	visible = false
	list_player.visible = false
	list.visible = true

	return {
		"index": last_index,
		"player": last_player
	}
