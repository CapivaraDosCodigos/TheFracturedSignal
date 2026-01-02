@icon("res://Resources/texturas/dunjoes.tres")
class_name Dungeons2D extends Node2D

@export_group("Nodes")
@export var players: SpawnPlayers
@export var inimigos: Node2D

@export_group("Som")
@export var tocarSom: bool = true
@export var DataAudio: DataAudioPlayer

signal end_batalha

func _ready() -> void:
	end_batalha.connect(terminar_batalha)
	Global.play_transition("end_transition")
	Manager.change_state("MAP")
	if tocarSom:
		Manager.tocar_musica(DataAudio)

func iniciar_batalha() -> void:
	Manager.change_state("DIALOGUE")
	players.visible = false
	inimigos.visible = false

func terminar_batalha() -> void:
	players.visible = true
	inimigos.visible = true
	Manager.tocar_musica(DataAudio)
	await get_tree().process_frame
	Manager.change_state("MAP")

func test(...args):
	print(args)
