extends Control

@onready var botoes: Array[Button] = [
	$Control/VBoxContainer/MarginContainer2/inicia1,
	$Control/VBoxContainer/MarginContainer3/inicia2,
	$Control/VBoxContainer/MarginContainer4/inicia3
]

var botao_index: int = 0

func _ready() -> void:
	#Manager.change_state(Manager.GameState.NOT_IN_THE_GAME)
	_atulizar()
	botoes[botao_index].grab_focus()
	
	match OS.get_name():
		"Windows":
			print("Welcome to Windows!")
		"macOS":
			print("Welcome to macOS!")
		"Linux", "FreeBSD", "NetBSD", "OpenBSD", "BSD":
			print("Welcome to Linux/BSD!")
		"Android":
			print("Welcome to Android!")
		"iOS":
			print("Welcome to iOS!")
		"Web":
			print("Welcome to the Web!")

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("Down"):
		if not botao_index == botoes.size() - 1:
			botao_index = (botao_index + 1) % botoes.size()
			botoes[botao_index].grab_focus()
		
	elif event.is_action_pressed("Up"):
		if not botao_index == 0:
			botao_index = (botao_index - 1 + botoes.size()) % botoes.size()
			botoes[botao_index].grab_focus()

	elif event.is_action_pressed("confirm"):
		botoes[botao_index].emit_signal("pressed")

func _atulizar() -> void:
	for i in botoes.size():
		if not ResourceLoader.exists(Database.SAVE_PATH % (i + 1)):
			#print(SaveData.CarregarTime(i + 1))
			botoes[i].text = "Iniciar Sistema " + str(i + 1) + "*"
		else:
			#botoes[i].text = "Volta Sistema " + str(i + 1) + "* " + SaveData.CarregarTime(i + 1)
			botoes[i].text = "Volta Sistema " + SaveData.CarregarTime(i + 1)

func _on_inicia_1_pressed() -> void:
	_start(1)

func _on_inicia_2_pressed() -> void:
	_start(2)

func _on_inicia_3_pressed() -> void:
	_start(3)

func _start(slot: int) -> void:
	await get_tree().process_frame
	Manager.Start_Save(slot)
	
	
