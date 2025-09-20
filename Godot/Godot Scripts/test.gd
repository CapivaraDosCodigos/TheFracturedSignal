@tool
extends Sprite2D

@export var red_tint: bool = false:
	set(value):
		red_tint = value
		if value:
			self.modulate = Color(1, 0, 0)
		else:
			self.modulate = Color(1, 1, 1)
