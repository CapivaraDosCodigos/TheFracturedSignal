extends VBoxContainer
class_name VBoxContainerButton

@export var texture_rect: TextureRect
@export var ButtonContainer: Button

func _process(_delta: float) -> void:
	texture_rect.visible = has_focus()
