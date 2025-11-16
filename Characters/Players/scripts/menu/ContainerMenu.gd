extends VBoxContainer

@export var texture_rect: TextureRect

func _process(_delta: float) -> void:
	texture_rect.visible = has_focus()
