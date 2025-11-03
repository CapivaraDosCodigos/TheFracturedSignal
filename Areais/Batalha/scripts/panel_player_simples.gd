extends VBoxContainer
class_name VContainerPlayerSimples

@export var player: String

@onready var texture: TextureRect = %Texture
@onready var life: Label = %life
@onready var act_label: Label = $ACTLabel
@onready var h_box_actions: HBoxContainer = $HBoxActions
@onready var actions: Array[Button] = [ %ATK, %ITM, %EXE, %DEF, %MRC ]

var isfocus: bool = false
var current_index: int = 0

func _ready() -> void:
	h_box_actions.visible = false
	act_label.visible = true

func _process(_delta: float) -> void:
	if Manager.PlayersAtuais.has(player):
		var playerNew: PlayerData = Manager.PlayersAtuais[player]
		life.text = str(playerNew.Life) + "/" + str(playerNew.maxlife)
	
	# alterna entre mostrar botões ou texto
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
