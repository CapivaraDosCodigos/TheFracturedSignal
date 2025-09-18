extends CharacterBody2D

@export var dungeons2D: Dungeons2D
@export var databatalha: DataBatalha

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		call_deferred("_trocar_para_batalha", body.global_position)

func _trocar_para_batalha(pos: Vector2) -> void:
	databatalha.dungeons2D = dungeons2D
	var set_pos = (pos + global_position) / 2
	Manager.StartBatalha(databatalha, set_pos)
	#Manager.tocar_musica_manager("res://sons/sounds/Deltarune - Sound Effect Battle Start Jingle(MP3_160K).mp3", 100, false, 0.0, 2)
	#await get_tree().create_timer(1.0).timeout
	#Manager.SceneTransition("res://Godot/Batalha/cenas/BATALHA.tscn")
