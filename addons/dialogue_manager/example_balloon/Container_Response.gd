extends VBoxContainer
class_name ContainerResponse

@export var texture_rect: TextureRect
@export var response_example: Button
@export var text: String = "":
	set(value):
		text = value
		if response_example != null:
			response_example.text = text

func _process(delta: float) -> void:
	texture_rect.visible = has_focus()
	
	if has_focus() and !Manager.isState("NOT_IN_THE_GAME"):
		_reset_color()

func _reset_color() -> void:
	if Manager.get_Player().Soul == PlayerData.Souls.Empty:
		texture_rect.modulate = Color(1.0, 1.0, 1.0)
	
	elif Manager.get_Player().Soul == PlayerData.Souls.Hope:
		texture_rect.modulate = Color(0.561, 0.494, 0.816)
