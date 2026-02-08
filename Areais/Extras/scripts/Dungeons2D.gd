@icon("res://Resources/texturas/dunjoes.tres")
class_name Dungeons2D
extends Node2D

@export_file("*.*tscn") var scene_file: String
@export var cena_id: String = ""
@export var state: Manager.GameState = Manager.GameState.MAP

@export_group("Nodes")
@export var players: SpawnPlayers
@export var inimigos: Node2D

@export_group("Som")
@export var tocarSom: bool = true
@export var DataAudio: DataAudioPlayer

@export_category("Animations")
@export var animation: AnimationPlayer
@export var play: StringName

func _ready() -> void:
	Global.play_transition("end_transition")

	if _Is_tocar_animacao():
		_tocar_animacao()
	else:
		_registrar_cena()
		set_state(Manager.GameStateString[state])

	if tocarSom and not Manager.audios.get(1).isAudio(DataAudio.caminho):
		Manager.tocar_musica(DataAudio)

func _Is_tocar_animacao() -> bool:
	if cena_id == "":
		return true
	
	return not Manager.Extras.cenasVistas.has(cena_id)

func _tocar_animacao() -> void:
	if animation and animation.has_animation(play):
		animation.play(play)
	else:
		# Não tem animação → registra direto
		_registrar_cena()
		set_state(Manager.GameStateString[state])

func _registrar_cena() -> void:
	if cena_id == "":
		return
	
	if not Manager.Extras.cenasVistas.has(cena_id):
		Manager.Extras.cenasVistas.append(cena_id)

func set_state(p_state: String) -> void:
	Manager.set_state(p_state)

func iniciar_batalha() -> void:
	#Manager.change_state("DIALOGUE")
	players.visible = false
	inimigos.visible = false

func terminar_batalha() -> void:
	players.visible = true
	inimigos.visible = true
	Manager.tocar_musica(DataAudio)
	await get_tree().process_frame
	Manager.change_state("MAP")
