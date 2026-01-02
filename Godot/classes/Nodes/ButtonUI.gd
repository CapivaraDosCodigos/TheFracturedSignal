extends Button
class_name ButtonUI

@export_group("Buttons")
@export var control_left: Control
@export var control_top: Control
@export var control_right: Control
@export var control_bottom: Control
@export var control_end: Control

@export_group("Alternativos")
@export var control_left_alternative: Control
@export var top_alternative:  Control
@export var control_right_alternative: Control
@export var control_bottom_alternative: Control
@export var control_end_alternative: Control


func _unhandled_input(event: InputEvent) -> void:
	if not has_focus():
		return

	if event.is_action_pressed("Left"):
		await get_tree().process_frame
		_mover_foco(control_left, control_left_alternative)

	elif event.is_action_pressed("Right"):
		await get_tree().process_frame
		_mover_foco(control_right, control_right_alternative)

	elif event.is_action_pressed("Up"):
		await get_tree().process_frame
		_mover_foco(control_top, top_alternative)
		
	elif event.is_action_pressed("Down"):
		await get_tree().process_frame
		_mover_foco(control_bottom, control_bottom_alternative)

	elif event.is_action_pressed("confirm"):
		await get_tree().process_frame
		_mover_foco(control_end, control_end_alternative)
		pressed.emit()

func _mover_foco(principal: Control, alternativo: Control) -> void:
	if principal != null and principal.visible:
		Manager.tocar_musica(PathsMusic.MODERN_3, 3)
		principal.grab_focus()
		return
	
	if alternativo != null and alternativo.visible:
		Manager.tocar_musica(PathsMusic.MODERN_3, 3)
		alternativo.grab_focus()
		return
