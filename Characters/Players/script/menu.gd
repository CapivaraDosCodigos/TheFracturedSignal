extends CanvasLayer

var menu := false

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("menu") and Manager.current_status == Manager.GameState.MAP:
		menu = !menu
		

func _process(_delta: float) -> void:
	if Manager.current_status == Manager.GameState.MAP:
		$UI_menu.visible = menu
	else:
		menu = false
		$UI_menu.visible = false

func _on_status_pressed() -> void:
	Starts.Return_To_Title()
