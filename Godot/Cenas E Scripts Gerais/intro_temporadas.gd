extends CanvasLayer
class_name IntroTemporadas

@export var scene_intro: PackedScene
@export var texture_intro: TextureRect
@export var esquetes: Array[Texture] = []
@export var dialogue: DialogueResource

var index: int = 0

func _ready() -> void:
	Global.play_transition("end_transition")
	Manager.NodeVariant = self
	DialogueManager.show_example_dialogue_balloon(dialogue, "start")

func open_scene() -> void:
	var duracao: float = Global.play_transition("start_transition")
	await get_tree().create_timer(duracao).timeout
	Manager.NodeVariant = null
	get_tree().change_scene_to_packed(scene_intro)

func next_texture() -> void:
	if esquetes.size() > index:
		texture_intro.texture = esquetes[index]
	index += 1
