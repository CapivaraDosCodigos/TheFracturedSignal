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

func _abrir_submenu(button: String) -> void:
	submenu_ativo = true
	match button:
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
	await get_tree().process_frame
			
	submenu_atual.grab_focus()

func _fechar_submenu() -> void:
	if submenu_atual:
		submenu_atual.fechar()
	submenu_ativo = false
	submenu_atual = null
	_focus_current_panel()

func _on_inventory_pressed() -> void:
	_abrir_submenu("inventory")

func _on_equipment_pressed() -> void:
	_abrir_submenu("equipment")

func _on_status_pressed() -> void:
	_abrir_submenu("status")

func _on_settings_pressed() -> void:
	_abrir_submenu("settings")
