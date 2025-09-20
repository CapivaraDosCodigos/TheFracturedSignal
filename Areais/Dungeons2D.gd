@icon("res://texture/folderTres/texturas/dunjoes.tres")
class_name Dungeons2D extends Node2D

@export_group("Nodes")
@export var players: Node2D
@export var inimigos: Node2D

@export_group("Som")
@export_file("*.*ogg", "*.*mp3") var caminho_audio: String = ""
@export_range(0.0, 100.0) var volume: float = 100.0
@export var loop: bool = true
@export_range(0.0, 30.0) var atraso: float = 0.0

signal end_batalha

func _ready() -> void:
	end_batalha.connect(terminar_batalha)
	Manager.tocar_musica_manager(caminho_audio, volume, loop, atraso)

func iniciar_batalha() -> void:
	Manager.change_state(Manager.GameState.DIALOGUE)
	players.visible = false
	inimigos.visible = false

func terminar_batalha() -> void:
	players.visible = true
	inimigos.visible = true
	Manager.tocar_musica_manager(caminho_audio, volume, loop, atraso)
	await get_tree().process_frame
	Manager.change_state(Manager.GameState.MAP)
