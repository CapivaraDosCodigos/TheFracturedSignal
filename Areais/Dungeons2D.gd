extends Node2D
class_name Dungeons2D

@export_group("Nodes")
@export var players: Node2D
@export var inimigos: Node2D

@export_group("Som")
@export_file("*.*ogg", "*.*mp3") var caminho_audio: String = ""
@export_range(0.0, 100.0) var volume: float = 100.0
@export var loop: bool = true
@export_range(0.0, 30.0) var atraso: float = 0.0

func _ready() -> void:
	Manager.tocar_musica_manager(caminho_audio, volume, loop, atraso)

func iniciar_batalha() -> void:
	Manager.change_state(Manager.GameState.DIALOGUE)
	players.visible = false
	inimigos.visible = false

func terminar_batalha() -> void:
	Manager.change_state(Manager.GameState.MAP)
	players.visible = true
	inimigos.visible = true
	Manager.tocar_musica_manager(caminho_audio, volume, loop, atraso)
