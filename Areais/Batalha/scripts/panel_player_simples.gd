extends PanelContainer
class_name ContainerPlayerSimples

@export var player: String

@onready var texture: TextureRect = %Texture
@onready var life: Label = %life
@onready var act_label: Label = %ACTLabel
@onready var h_box_actions: HBoxContainer = %HBoxActions
@onready var itens_menu: batalha_submenu_itens = %itensMenu
@onready var inimigos_menu: batalha_submenu_enemies = %inimigosMenu
@onready var actions: Array[Control] = [ %ATK, %ITM, %EXE, %DEF, %MRC ]

var isfocus: bool = false
var current_index: int = 0

func _ready() -> void:
	h_box_actions.visible = false
	act_label.visible = true

func _process(_delta: float) -> void:
	if Manager.PlayersAtuais.has(player):
		life.text = str(Manager.PlayersAtuais[player].Life) + "/" + str(Manager.PlayersAtuais[player].maxlife)
		act_label.text = player
	
	h_box_actions.visible = isfocus
	act_label.visible = !isfocus

func set_focus(active: bool) -> void:
	isfocus = active
	if active:
		current_index = 0
		_focus_button()

func _focus_button() -> void:
	if actions.is_empty():
		return
	await get_tree().process_frame
	actions[current_index].grab_focus()

func next_button() -> void:
	if not isfocus:
		return
	current_index = min(current_index + 1, actions.size() - 1)
	_focus_button()

func previous_button() -> void:
	if not isfocus:
		return
	current_index = max(current_index - 1, 0)
	_focus_button()

func get_current_action_name() -> String:
	if current_index >= 0 and current_index < actions.size():
		return actions[current_index].name
	return ""

func fechar_submenus() -> void:
	itens_menu.end()
	inimigos_menu.end()

func get_submenu(menu: String) -> Node:
	match menu:
		"ITM": return itens_menu
		"ATK": return inimigos_menu
		_: return null
