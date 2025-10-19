extends StaticBody2D

func _process(_delta: float) -> void:
	if Manager.Body == self and Manager.current_status == Manager.GameState.MAP:
		for i in Manager.PlayersAtuais.keys():
			Manager.PlayersAtuais[i].Life = Manager.PlayersAtuais[i].maxlife
		Manager.SAVE(Manager.Data.slot)
