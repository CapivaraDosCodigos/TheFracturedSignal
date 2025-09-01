extends Sprite2D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Manager.InteractionMode == "balloonZ":
		%balloonZ.visible = true
	elif Manager.InteractionMode == "magnifyingZ":
		%magnifyingZ.visible = true
	elif Manager.InteractionMode == "takeZ":
		%takeZ.visible = true
	elif Manager.InteractionMode == "questionZ":
		%questionZ.visible = true
	else:
		%balloonZ.visible = false
		%magnifyingZ.visible = false
		%takeZ.visible = false
		%questionZ.visible = false
	
