extends StaticBody2D

func _process(_delta: float) -> void:
	if Manager.Body == self and Manager.current_status == Manager.GameState.MAP:
		Manager.SAVE(Manager.Data.slot)
