extends ColorRect

@onready var button_ui: ButtonUI = $VBoxContainer/VBoxContainer/MarginContainer/ButtonUI1
@onready var morte: Label = $VBoxContainer/VBoxContainer/morte

func _ready() -> void:
	Manager.change_state(Manager.GameState.NOT_IN_THE_GAME)
	button_ui.grab_focus()

func _on_button_ui_1_pressed() -> void:
	Manager.Start_Save(Manager.CurrentSlot, Manager.CurrentTemporada)

func _on_button_ui_2_pressed() -> void:
	Manager.Return_To_Title()
