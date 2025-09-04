extends ObjectPlayer

func _ready() -> void:
	Manager.tocar_musica_manager("res://sons/music/acid_tunnel.ogg", 90, true)
	#Manager.nova_palette("res://addons/post_processing/assets/green_palette.png", true)

func _physics_process(_delta) -> void:
	if Manager.current_status == Manager.GameState.MAP:
		player_physics()
		follower_physics()
	
	elif Manager.current_status == Manager.GameState.DIALOGUE:
		update_animation(Vector2.ZERO)

func player_physics() -> void:
	if $MENU.menu:
		update_animation(Vector2.ZERO)
		return
	super.player_physics()
