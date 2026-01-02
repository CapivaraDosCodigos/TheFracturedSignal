extends CanvasLayer

@onready var buttons: Array[Control] = [
	%inventory,
	%equipment,
	%status,
	%settings ]
@onready var submenus: Array[SubMenuBase] = [
	%InventoryMenu,
	%EquipmentMenu,
	%StatusMenu,
	%SettingsMenu ]

@onready var ui_menu: Control = $UI_menu

var current_index: int = 0
var submenu_ativo: bool = false
var submenu_atual: SubMenuBase = null

func _ready() -> void:
	ui_menu.visible = false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("menu"):
		if Manager.isState("MAP"):
			_abrir_menu()
		elif Manager.isState("MENU"):
			_fechar_menu()
		return

	if not Manager.isState("MENU"):
		return

	if submenu_ativo:
		if event.is_action_pressed("cancel"):
			_fechar_submenu()
		return

	if event.is_action_pressed("Right"):
		current_index = (current_index + 1) % buttons.size()
		_focus_current_panel()

	elif event.is_action_pressed("Left"):
		current_index = (current_index - 1 + buttons.size()) % buttons.size()
		_focus_current_panel()

	elif event.is_action_pressed("confirm"):
		_abrir_submenu(buttons[current_index])

	elif event.is_action_pressed("cancel"):
		_fechar_menu()

func _process(_delta: float) -> void:
	ui_menu.visible = Manager.isState("MENU")

func _abrir_menu() -> void:
	Manager.change_state("MENU")
	ui_menu.visible = true
	current_index = 0
	_focus_current_panel()

func _fechar_menu() -> void:
	_fechar_submenu()
	ui_menu.visible = false
	Manager.change_state("MAP")

func _focus_current_panel() -> void:
	if not buttons.is_empty():
		await get_tree().process_frame
		buttons[current_index].grab_focus()
		for submenu in submenus:
			submenu.fechar()

func _abrir_submenu(button: Control) -> void:
	submenu_ativo = true

	match button.name:
		"inventory":
			submenu_atual = %InventoryMenu
		"equipment":
			submenu_atual = %EquipmentMenu
		"status":
			submenu_atual = %StatusMenu
		"settings":
			submenu_atual = %SettingsMenu
		_:
			submenu_ativo = false
			return

	submenu_atual.abrir()

func _fechar_submenu() -> void:
	if submenu_atual:
		Global.Salvar_Arquivo()
		submenu_atual.fechar()

	submenu_atual = null
	submenu_ativo = false
	_focus_current_panel()
