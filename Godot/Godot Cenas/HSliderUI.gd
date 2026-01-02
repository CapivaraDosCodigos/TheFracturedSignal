extends HSlider
class_name HSliderUI

@export var text: String = ""
@export var texture: TextureRect
@export var label: Label

@export_group("Buttons")
@export var control_top: Control
@export var control_bottom: Control
@export var control_end: Control

func _process(_delta: float) -> void:
	texture.visible = has_focus()
	label.text = text % [int(value)]

func _unhandled_input(event: InputEvent) -> void:
	if not has_focus():
		return
	
	elif Input.is_action_pressed("Left"):
		if value - 1 >= 0:
			value -= 1
	
	elif Input.is_action_pressed("Right"):
		if value + 1 <= max_value:
			value += 1
	
	elif event.is_action_pressed("Up"):
		await get_tree().process_frame
		_mover_foco(control_top)
		
	elif event.is_action_pressed("Down"):
		await get_tree().process_frame
		_mover_foco(control_bottom)

func _mover_foco(principal: Control) -> void:
	if principal != null and principal.visible:
		Manager.tocar_musica(PathsMusic.MODERN_3, 2)
		principal.grab_focus()
		return
