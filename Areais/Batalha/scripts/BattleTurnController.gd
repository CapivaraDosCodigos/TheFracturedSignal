@icon("res://texture/PNG/icon/godot/terminal-2.svg")
class_name BattleTurnController
extends Node

var playersDir: Dictionary[String, PlayerData] = {}
var playersKeys: Array[String] = []

var submenu_resultados: Dictionary = {}
var selecoes: Dictionary[String, String] = {}
var jogador_atual: String = ""
var selecao_ativa: bool = false
var selecao_finalizada: bool = false
var turn: int = 0

func setup(players: Dictionary[String, PlayerData]) -> void:
	playersDir = players
	playersKeys = players.keys()
	selecao_ativa = false
	selecao_finalizada = false
	jogador_atual = ""

func iniciar_selecao() -> void:
	selecao_ativa = true
	selecao_finalizada = false
	
	submenu_resultados.clear()
	selecoes.clear()
	
	jogador_atual = proximo_jogador_valido()
	turn += 1
	#print(turn)
	
	for player: PlayerData in playersDir.values():
		player.apply_effects()
		player.isDefesa = false

func finalizar_selecao() -> void:
	selecao_ativa = false
	selecao_finalizada = true
	jogador_atual = ""

func avancar_turno() -> void:
	if not selecao_ativa:
		return

	var idx: int = playersKeys.find(jogador_atual)
	var prox: String = proximo_jogador_valido(idx + 1)

	while prox != "" and deve_pular_jogador(prox):
		prox = proximo_jogador_valido(playersKeys.find(prox) + 1)

	jogador_atual = prox

	if jogador_atual == "":
		finalizar_selecao()

func voltar_turno() -> String:
	if not selecao_ativa:
		return ""

	var idx := playersKeys.find(jogador_atual)
	if idx <= 0:
		return ""

	var anterior := playersKeys[idx - 1]
	while idx > 0 and deve_pular_jogador(anterior):
		idx -= 1
		anterior = playersKeys[idx]

	jogador_atual = anterior
	return jogador_atual

func proximo_jogador_valido(inicio: int = 0) -> String:
	for i in range(inicio, playersKeys.size()):
		var key: String = playersKeys[i]

		if not playersDir.has(key):
			continue

		var player: PlayerData = playersDir[key]
		if player.fallen or player.skip_turn:
			continue

		return key

	return ""

# TODO fazer tal coisa
func deve_pular_jogador(key: String) -> bool:
	if not playersDir.has(key):
		return true

	var player: PlayerData = playersDir[key]
	return player.fallen or player.skip_turn
