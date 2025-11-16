extends Node2D
class_name PersonagensBatalha2D

@onready var inimigoMarker2D: Array[Marker2D] = [ $inimigo1, $inimigo2, $inimigo3 ]
@onready var playerMarker2D: Array[Marker2D] = [ $player1, $player2, $player3 ]

var index_player: int = 0

var menu_bool: bool = false
var last_index: int = -1

func _ready() -> void:
	for i in playerMarker2D:
		i.visible = false

func menuPersonagens() -> int:
	menu_bool = true
	atualizar_sprites()
	index_player = 0
	
	while menu_bool:
		await get_tree().process_frame
	
	var result := last_index
	last_index = -1
	return result

func _unhandled_input(event: InputEvent) -> void:
	if not menu_bool:
		return
	
	if event.is_action_pressed("Down"):
		if index_player < playerMarker2D.size() - 1:
			index_player += 1
			atualizar_sprites()
	
	elif event.is_action_pressed("Up"):
		if index_player > 0:
			index_player -= 1
			atualizar_sprites()

	elif event.is_action_pressed("confirm"):
		last_index = index_player
		end()
	
	elif event.is_action_pressed("cancel"):
		last_index = -1
		end()

func end() -> void:
	for i in playerMarker2D:
		i.visible = false
	
	menu_bool = false

func atualizar_sprites() -> void:
	for i in playerMarker2D:
		i.visible = false
		
	playerMarker2D[index_player].visible = true
