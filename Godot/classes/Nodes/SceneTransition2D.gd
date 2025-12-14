extends Area2D
class_name SceneTransition2D

@export var cena: PackedScene

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body is ObjectPlayer2D:
		if body.Nome == Manager.CurrentPlayerString:
			call_deferred("Transition")

func Transition() -> void:
	if cena:
		var duracao: float = Global.play_transition("start_transition")
		await get_tree().create_timer(duracao).timeout
		get_tree().change_scene_to_packed(cena)
	
