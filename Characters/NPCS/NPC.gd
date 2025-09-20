@icon("res://texture/folderTres/texturas/npc.tres")
class_name NPC extends AnimatableBody2D

@export var dialogue: DialogueResource
@export var start_dialogo: String

func _process(_delta: float) -> void:
	if Manager.Body == self and Manager.current_status == Manager.GameState.MAP:
		DialogueManager.show_example_dialogue_balloon(dialogue, start_dialogo)
