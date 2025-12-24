extends PanelContainer
class_name BatalhaSubmenuPlayers

@onready var botoes: Array[InimigoButton] = [ %Player1, %Player2, %Player3 ]

var players_dis: Array[PlayerData] = []
var current_index := 0
var selecting := false
var last_player := ""

func _ready() -> void:
	visible = false
	set_process_unhandled_input(false)

func selecionar() -> String:
	current_index = 0
	last_player = ""
	selecting = true

	visible = true
	set_process_unhandled_input(true)

	_focus_button()

	while selecting:
		await get_tree().process_frame

	visible = false
	set_process_unhandled_input(false)

	return last_player

func _unhandled_input(event: InputEvent) -> void:
	if not selecting:
		return

	if event.is_action_pressed("Down"):
		current_index = (current_index + 1) % players_dis.size()
		_focus_button()

	elif event.is_action_pressed("Up"):
		current_index = (current_index - 1 + players_dis.size()) % players_dis.size()
		_focus_button()

	elif event.is_action_pressed("confirm"):
		last_player = players_dis[current_index].Nome
		end()

	elif event.is_action_pressed("cancel"):
		last_player = ""
		end()

func _focus_button() -> void:
	if current_index >= 0 and current_index < botoes.size() and botoes[current_index].visible:
		await get_tree().process_frame
		botoes[current_index].grab_focus()

func atualizar_players(players: Array[PlayerData]) -> void:
	players_dis = players
	for b in botoes:
		b.visible = false

	for i in range(min(players.size(), botoes.size())):
		var p := players[i]
		var btn := botoes[i]

		btn.visible = true
		btn.nome.text = p.Nome
		btn.life.max_value = p.maxlife
		btn.life.value = p.Life

func end() -> void:
	selecting = false
	visible = false
