extends Control

@onready var botoes: Array[Button] = [
	$Control/VBoxContainer/MarginContainer2/inicia1,
	$Control/VBoxContainer/MarginContainer3/inicia2,
	$Control/VBoxContainer/MarginContainer4/inicia3
]

var botao_index: int = 0

func _ready() -> void:
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
		botao_index = clamp(botao_index + 1, 0, botoes.size() - 1)
		botoes[botao_index].grab_focus()

	elif event.is_action_pressed("Up"):
		botao_index = clamp(botao_index - 1, 0, botoes.size() - 1)
		botoes[botao_index].grab_focus()

	elif event.is_action_pressed("confirm"):
		botoes[botao_index].emit_signal("pressed")

func _process(_delta: float) -> void:
	for i in botoes.size():
		if not ResourceLoader.exists(Database.SAVE_PATH % (i + 1)):
			botoes[i].text = "Iniciar Sistema " + str(i + 1) + "*"
		else:
			botoes[i].text = "Volta Sistema " + str(i + 1) + "*"

func _on_inicia_1_pressed() -> void:
	await get_tree().process_frame
	Starts.Start_Save(1)

func _on_inicia_2_pressed() -> void:
	await get_tree().process_frame
	Starts.Start_Save(2)

func _on_inicia_3_pressed() -> void:
	await get_tree().process_frame
	Starts.Start_Save(3)
