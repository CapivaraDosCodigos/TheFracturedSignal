extends NinePatchRect
class_name BattleArenaControl

@onready var ambicao: AlmaBody2D = %"Ambição"
@onready var ambicao_make: Marker2D = %AmbiçãoMake
@onready var objetos: Node2D = $objetos

var last_state = null

func _process(_delta: float) -> void:
	var current_state = Manager.CurrentStatus
	if current_state != last_state:
		if current_state == Manager.GameState.BATTLE:
			ambicao.position = ambicao_make.position
			#ambicao.visible = true
			
		elif current_state == Manager.GameState.BATTLE_MENU:
			pass
			#ambicao.visible = false
			
		last_state = current_state
