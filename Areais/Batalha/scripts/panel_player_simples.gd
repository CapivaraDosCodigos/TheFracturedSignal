extends PanelContainer
class_name ContainerPlayer

@export var player: String

@onready var texture: TextureRect = %Texture
@onready var life: Label = %life
@onready var actions_label: Label = %ActionsLabel
@onready var act_label: Label = %ACTLabel
@onready var h_box_actions: HBoxContainer = %HBoxActions
@onready var itens_menu: BatalhaSubmenuItens = %itensMenu
@onready var inimigos_menu: BatalhaSubmenuEnemies = %inimigosMenu
@onready var executable_menu: BatalhaSubmenuExecutable = %ExecutableMenu
@onready var player_menu: BatalhaSubmenuPlayers = %playerMenu
@onready var actions: Array[Control] = [ %ATK, %ITM, %EXE, %DEF, %ACT ]

var action_display_names: Dictionary[String, String] = {
	"ATK": "Atacar",
	"ITM": "Item",
	"EXE": "Executar",
	"DEF": "Defender",
	"MRC": "Agir" }
var isfocus: bool = false
var current_index: int = 0

func _ready() -> void:
	h_box_actions.visible = false
	act_label.visible = true
	actions_label.visible = false

func _process(_delta: float) -> void:
	if Manager.PlayersAtuais.has(player):
		var playerProcess: PlayerData = Manager.get_Player(player)
		life.text = str(playerProcess.Life) + "/" + str(playerProcess.maxlife)
		act_label.text = player
		texture.texture = playerProcess.Icone
	
	act_label.visible = !isfocus
	h_box_actions.visible = isfocus
	
	_update_actions_label()

func _focus_button() -> void:
	if actions.is_empty():
		return
	await get_tree().process_frame
	actions[current_index].grab_focus()

func _update_actions_label() -> void:
	if not _can_show_actions_label():
		actions_label.visible = false
		return
	
	actions_label.visible = true
	
	var action_name := get_current_action_name()
	if action_display_names.has(action_name):
		actions_label.text = action_display_names[action_name]
	else:
		actions_label.text = action_name

func _can_show_actions_label() -> bool:
	return isfocus and Manager.current_status == Manager.GameState.BATTLE_MENU

func set_focus(active: bool) -> void:
	isfocus = active
	
	if active:
		current_index = 0
		_focus_button()
	
	_update_actions_label()

func next_button() -> void:
	if not isfocus:
		return
	
	current_index = min(current_index + 1, actions.size() - 1)
	_focus_button()
	_update_actions_label()

func previous_button() -> void:
	if not isfocus:
		return
	
	current_index = max(current_index - 1, 0)
	_focus_button()
	_update_actions_label()

func get_current_action_name() -> String:
	if current_index >= 0 and current_index < actions.size():
		return actions[current_index].name
	return ""

func fechar_submenus() -> void:
	itens_menu.end()
	inimigos_menu.end()
	player_menu.end()
	executable_menu.end()

func get_submenu(menu: String) -> Node:
	match menu:
		"ITM": return itens_menu
		"ATK": return inimigos_menu
		"EXE": return executable_menu
		_: return null
