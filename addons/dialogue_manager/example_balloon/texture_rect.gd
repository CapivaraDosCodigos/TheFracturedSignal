extends NinePatchRect

@onready var texture_rect: TextureRect = $TextureRect

func _process(delta: float) -> void:
	texture_rect.texture = Manager.textureD
	texture_rect.material = Manager.materialD
	if Manager.textureD != null:
		visible = true
	else:
		visible = false
