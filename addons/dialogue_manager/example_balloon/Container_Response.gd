extends VBoxContainer
class_name Container_Response

@export var texture_rect: TextureRect
@export var response_example: Button
@export var text: String = "":
	set(value):
		text = value
		if response_example != null:
			response_example.text = text

func _process(delta: float) -> void:
	if has_focus():
		texture_rect.visible = true
	else:
		texture_rect.visible = false
