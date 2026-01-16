extends StaticBody2D

func _process(_delta: float) -> void:
	if Manager.Body == self and Manager.isState("MAP"):
		var current_scene: Node = get_tree().current_scene
		if current_scene is Dungeons2D:
			Manager.CurrentScene = current_scene.scene_file
		Manager.SAVE(Manager.CurrentSlot)
