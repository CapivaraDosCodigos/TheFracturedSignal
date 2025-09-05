extends ObjectPlayer

func _ready() -> void:
# Desativar a câmera
	#$Camera.current = false
		# Ativar esta câmera
	$Camera.enabled = false
	#$OutraCamera.current = true
	Manager.tocar_musica_manager("res://sons/music/acid_tunnel.ogg", 90, true)
	#Manager.nova_palette("res://addons/post_processing/assets/green_palette.png", true)

func _physics_process(_delta) -> void:
	if Manager.current_status == Manager.GameState.MAP:
		player_physics()
		follower_physics()
	
	elif Manager.current_status == Manager.GameState.DIALOGUE:
		update_animation(Vector2.ZERO)
