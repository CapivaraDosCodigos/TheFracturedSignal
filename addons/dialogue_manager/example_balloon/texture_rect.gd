extends Panel

@onready var texture_rect: TextureRect = $MarginContainer/TextureRect

func _process(delta: float) -> void:
	texture_rect.texture = Manager.textureD
	if Manager.textureD != null:
		visible = true
	else:
		visible = false
