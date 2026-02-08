extends Button
class_name ButtonUI

@export var icon_alma: Texture
var icon_reset: Texture

@export_group("Buttons")
@export var control_left: Control
@export var control_top: Control
@export var control_right: Control
@export var control_bottom: Control
@export var control_end: Control

@export_group("Alternativos")
@export var control_left_alternative: Control
@export var top_alternative: Control
@export var control_right_alternative: Control
@export var control_bottom_alternative: Control
@export var control_end_alternative: Control


func _ready() -> void:
	icon_reset = icon
	focus_entered.connect(_on_focus_entered)
	focus_exited.connect(_on_focus_exited)

func _on_focus_entered() -> void:
	icon = icon_alma
	_atualizar_cor_icon()

func _on_focus_exited() -> void:
	icon = icon_reset
	modulate = Color.WHITE

func _atualizar_cor_icon() -> void:
	if Manager.isState("NOT_IN_THE_GAME"):
		modulate = Color.WHITE
		return

	var player: PlayerData = Manager.get_Player()
	if not player:
		return
	match player.Soul:
		PlayerData.Souls.Empty:
			modulate = Color.WHITE

		PlayerData.Souls.Hope:
			modulate = Color(0.561, 0.494, 0.816)

		_:
			modulate = Color.WHITE

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
