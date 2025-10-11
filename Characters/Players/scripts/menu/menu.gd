extends CanvasLayer

@onready var buttons: Array[Button] = [ %inventory, %equipment, %status, %settings ]

var current_index: int = 0
var menu: bool = false
var submenu_ativo: bool = false
var submenu_atual: SubMenuBase = null

func _unhandled_input(event: InputEvent) -> void:
	# Abrir/fechar menu principal
	if event.is_action_pressed("menu") and Manager.current_status == Manager.GameState.MAP:
		menu = !menu
		if menu:
			current_index = 0
			_focus_current_panel()
		else:
			_fechar_submenu()
		return

	# Se o menu não está ativo, sai
	if not menu:
		return

	# Se um submenu está ativo, deixa ele controlar o input
	if submenu_ativo:
		if event.is_action_pressed("cancel"):
			_fechar_submenu()
		return

	# Navegação lateral
	if event.is_action_pressed("Right"):
		if current_index < buttons.size() - 1:
			current_index = (current_index + 1) % buttons.size()
			_focus_current_panel()

	elif event.is_action_pressed("Left"):
		if current_index > 0:
			current_index = (current_index - 1 + buttons.size()) % buttons.size()
			_focus_current_panel()

	# Confirmar opção
	elif event.is_action_pressed("confirm"):
		_abrir_submenu(buttons[current_index])

	# Cancelar -> fecha o menu principal
	elif event.is_action_pressed("cancel"):
		menu = false
		$UI_menu.visible = false

func _process(_delta: float) -> void:
	if Manager.current_status == Manager.GameState.MAP:
		$UI_menu.visible = menu
	else:
		menu = false
		$UI_menu.visible = false

func _focus_current_panel():
	if menu and buttons[current_index]:
		await get_tree().process_frame
		buttons[current_index].grab_focus()

func _abrir_submenu(button: Button) -> void:
	submenu_ativo = true
	match button.name:
		"inventory":
			print("Abrindo Inventário")
			submenu_atual = %InventoryMenu
			
		"equipment":
			print("Abrindo Equipamentos")
			submenu_atual = %EquipmentMenu
			
		"status":
			print("Abrindo Status")
			submenu_atual = %StatusMenu
			
		"settings":
			Manager.Return_To_Title()
			menu = false
			$UI_menu.visible = false
			return
			#print("Abrindo Configurações")
			#submenu_atual = %SettingsMenu
		
	submenu_atual.abrir()

func _fechar_submenu() -> void:
	if submenu_atual:
		submenu_atual.fechar()
	submenu_ativo = false
	submenu_atual = null
	_focus_current_panel()
