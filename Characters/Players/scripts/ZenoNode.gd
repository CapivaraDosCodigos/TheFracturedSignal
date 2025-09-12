extends ObjectPlayer

func _ready() -> void:
	pass
	#Manager.tocar_musica_manager("res://sons/music/acid_tunnel.ogg", 90, true)
	#Manager.nova_palette("res://addons/post_processing/assets/green_palette.png", true)

func _process(_delta: float) -> void:
	if Manager.current_status == Manager.GameState.MAP:
		if Starts.Current_player:
			no_player = not (Starts.Current_player.Nome == Nome)
		player_physics()
		follower_physics()
	
	elif Manager.current_status == Manager.GameState.DIALOGUE:
		update_animation(Vector2.ZERO)
