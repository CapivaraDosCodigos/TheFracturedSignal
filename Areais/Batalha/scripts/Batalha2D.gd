@icon("res://Resources/texturas/batalha.tres")
class_name Batalha2D
extends Node2D

#region vars

const MAX_ENENINES: int = 3

@onready var containersPlayers: Array[ContainerPlayer] = [ %ContainerPlayer1, %ContainerPlayer2, %ContainerPlayer3 ]
@onready var entityManager : BattleEntityManager2D = $BatalhaCanvas/BattleEntityManager2D
@onready var turnController: BattleTurnController = $BattleTurnController
@onready var pointsProgressBar: TextureProgressBar = %PointsProgressBar
@onready var battleArena: BattleArenaControl = %BATTLE_ARENA
@onready var anim: AnimationPlayer = $AnimationPanel

var itemsTemporarios: Dictionary[String, DataItem] = {}
var cp_delta_por_jogador: Dictionary[String, int] = {}

var itemsLocais: Array[DataItem] = []
var PlayersDIR: Dictionary[String, PlayerData] = {}

var batalha: DataBatalha = null
var lastState = null

var concentration_points_visual: float = 0.0
var concentration_points: int = 0
var submenuAtivo: bool = false

#endregion

func _ready() -> void:
	while batalha.inimigos.size() > MAX_ENENINES:
		batalha.inimigos.pop_back()

	PlayersDIR = Manager.PlayersAtuais
	turnController.playersKeys = PlayersDIR.keys()

	turnController.setup(PlayersDIR)

	for idx in PlayersDIR.size():
		entityManager.adicionar_jogador(idx, turnController.playersKeys[idx], PlayersDIR, containersPlayers)

	for i in batalha.inimigos.size():
		entityManager.adicionar_inimigo(batalha.inimigos[i], i)

	await get_tree().create_timer(1.5).timeout
	DialogueManager.show_example_dialogue_balloon(load(batalha.dialogo), batalha.start_dialogo)
	Manager.tocar_musica(batalha.DataAudio, 1)

func _process(delta: float) -> void:
	var state = Manager.CurrentStatus
	if state != lastState:

		if state == Manager.GameState.BATTLE:
			anim.play("S_panel")
			for container in containersPlayers:
				container.isfocus = false

		elif state == Manager.GameState.BATTLE_MENU:
			anim.play("E_panel")
			_iniciar_selecao()
		
		lastState = state
	
	if lastState == Manager.GameState.BATTLE_MENU and state != Manager.GameState.BATTLE_MENU:
		cp_delta_por_jogador.clear()

	concentration_points_visual = lerp(concentration_points_visual, float(concentration_points), 8.0 * delta)

	pointsProgressBar.value = concentration_points_visual
	$BatalhaCanvas/VBoxContainer/Label.text = str(round(concentration_points_visual))
	
	if entityManager.verificar_dead():
		dead_batalha()

func _unhandled_input(event: InputEvent) -> void:
	if not turnController.selecao_ativa or turnController.selecao_finalizada:
		return
	
	var container: ContainerPlayer = _get_container_player(turnController.jogador_atual)
	if not container:
		return
	
	if submenuAtivo:
		if event.is_action_pressed("cancel"):
			Manager.tocar_musica(PathsMusic.CANCEL, 3)
			_fechar_submenu()
		return

	if event.is_action_pressed("Right"):
		Manager.tocar_musica(PathsMusic.MODERN_5, 2)
		container.next_button()

	elif event.is_action_pressed("Left"):
		Manager.tocar_musica(PathsMusic.MODERN_5, 2)
		container.previous_button()

	elif event.is_action_pressed("confirm"):
		Manager.tocar_musica(PathsMusic.MODERN_9, 3)
		_abrir_submenu(container.get_current_action_name())
	
	elif event.is_action_pressed("cancel"):
		Manager.tocar_musica(PathsMusic.CANCEL, 3)
		_cancelar_jogador_anterior()

func _iniciar_selecao() -> void:
	itemsTemporarios.clear()
	cp_delta_por_jogador.clear()

	itemsLocais = Manager.get_Inventory().get_in_items_batalha().duplicate(true)

	turnController.iniciar_selecao()
	_focus_container_atual()

func _abrir_submenu(act: String) -> void:
	var container: ContainerPlayer = _get_container_player(turnController.jogador_atual)
	if not container: return
	
	match act:
		"DEF", "ACT":
			_confirmar_acao(act)
	
		"ATK":
			submenuAtivo = true
			container.inimigos_menu.atualizar_inimigos(entityManager.enemiesNodes)
			var res: int = await container.inimigos_menu.get_inimigo()
			if res >= 0:
				turnController.submenu_resultados[turnController.jogador_atual] = res
				_confirmar_acao(act, res)
			container.fechar_submenus()
			submenuAtivo = false
	
		"EXE":
			submenuAtivo = true
			if PlayersDIR[turnController.jogador_atual].get_Executables().is_empty():
				container.fechar_submenus()
				submenuAtivo = false
				_focus_container_atual()
				return
			
			container.inimigos_menu.atualizar_inimigos(entityManager.enemiesNodes)
			container.player_menu.atualizar_players(PlayersDIR.values())
			var result: Dictionary = await container.executable_menu.get_Executable(PlayersDIR[turnController.jogador_atual])
			if result["index"] >= 0:
				var exe: Executable = PlayersDIR[turnController.jogador_atual].get_Executables().get(result["index"])
				turnController.submenu_resultados[turnController.jogador_atual] = {
					"exe": exe,
					"Dictionary": { "player": result["player"], "inimigo": result["inimigo"] }
				}
				_confirmar_acao(act)

			container.fechar_submenus()
			submenuAtivo = false
	
		"ITM":
			submenuAtivo = true
			if itemsLocais.is_empty():
				container.fechar_submenus()
				submenuAtivo = false
				_focus_container_atual()
				return
				
			container.itens_menu.atualizar_itemlist(itemsLocais)
			container.player_menu.atualizar_players(PlayersDIR.values())
			
			var result: Dictionary = await container.itens_menu.itemsIvt()
			if result["index"] >= 0 and result["index"] < itemsLocais.size():
				var item: DataItem = itemsLocais[result["index"]]
				turnController.submenu_resultados[turnController.jogador_atual] = {
					"item": item,
					"player": result["player"],
					"index": result["index"]
				}
				itemsTemporarios[turnController.jogador_atual] = item
				itemsLocais.erase(item)
				container.itens_menu.atualizar_itemlist(itemsLocais)
				_confirmar_acao(act)

			container.fechar_submenus()
			submenuAtivo = false
		
		_:
			Manager.tocar_musica(PathsMusic.SCI_FI_ERROR, 2)

func _confirmar_acao(nome: String, _extra = null) -> void:
	var jogador: String = turnController.jogador_atual

	if cp_delta_por_jogador.has(jogador):
		_reverter_concentration_temporario(jogador)

	match nome:
		"DEF":
			var ganho: int = min(10, 100 - concentration_points)
			if ganho > 0:
				aplicar_concentration_temporario(jogador, ganho)

		"EXE":
			var res: Dictionary = turnController.submenu_resultados[jogador]
			var exe: Executable = res["exe"]
			exe.coprando()

	turnController.selecoes[jogador] = nome

	turnController.avancar_turno()

	if turnController.selecao_finalizada:
		for key in turnController.playersKeys:
			_act(turnController.selecoes.get(key, ""), key)

		cp_delta_por_jogador.clear()
		Manager.set_state("BATTLE")
	else:
		_focus_container_atual()

func _cancelar_jogador_anterior() -> void:
	var jogador_cancelado: String = turnController.voltar_turno()
	if jogador_cancelado == "":
		return

	if turnController.submenu_resultados.has(jogador_cancelado):
		var dado = turnController.submenu_resultados[jogador_cancelado]
		if typeof(dado) == TYPE_DICTIONARY and dado.has("item"):
			var item: DataItem = dado["item"]
			var index_original: int = dado.get("index", itemsLocais.size())
			index_original = clamp(index_original, 0, itemsLocais.size())
			itemsLocais.insert(index_original, item)

		turnController.submenu_resultados.erase(jogador_cancelado)
		itemsTemporarios.erase(jogador_cancelado)
		turnController.selecoes.erase(jogador_cancelado)

	if cp_delta_por_jogador.has(jogador_cancelado):
		_reverter_concentration_temporario(jogador_cancelado)

	_focus_container_atual()

func _focus_container_atual() -> void:
	for container in containersPlayers:
		container.set_focus(false)

	var key: String = turnController.jogador_atual
	var idx: int = turnController.playersKeys.find(key)

	if idx >= 0 and idx < containersPlayers.size():
		containersPlayers[idx].set_focus(true)

func _get_container_player(key: String) -> ContainerPlayer:
	var idx: int = turnController.playersKeys.find(key)

	if idx >= 0 and idx < containersPlayers.size():
		return containersPlayers[idx]

	return null

func _fechar_submenu() -> void:
	submenuAtivo = false
	var cont: ContainerPlayer = _get_container_player(turnController.jogador_atual)
	if cont:
		cont.fechar_submenus()
	_focus_container_atual()

func _act(act: String, key: String) -> void:
	if act == "ATK":
		if not turnController.submenu_resultados.has(key):
			return
			
		var inimigo_id = turnController.submenu_resultados[key]
		var inimigo = entityManager.enemiesNodes.get(inimigo_id, null)
		
		if inimigo != null:
			inimigo.apply_damage(PlayersDIR[key].maxDamage)
			#print(PlayersDIR[key].maxDamage, " dano do player ", key)

		await get_tree().process_frame
		if entityManager.enemiesNodes.is_empty():
			return

	elif act == "DEF":
		PlayersDIR[key].isDefesa = true
	
	elif act == "EXE":
		var resut: Dictionary = turnController.submenu_resultados[key]
		var exe: Executable = resut["exe"]
		exe.executar(turnController.submenu_resultados[key].get("Dictionary"))
	
	elif act == "ITM":
		if not turnController.submenu_resultados.has(key):
			return
	
		var item_usado: DataItem = turnController.submenu_resultados[key].get("item")
		if item_usado == null:
			return
	
		item_usado.usar(turnController.submenu_resultados[key].get("player"))
	
		Manager.get_Inventory().remove_for_item(item_usado)
		var container :ContainerPlayer = _get_container_player(key)
		if container:
			container.itens_menu.atualizar_itemlist()
	
	elif act == "ACT":
		pass

func _reverter_concentration_temporario(jogador: String) -> void:
	if not cp_delta_por_jogador.has(jogador):
		return
	
	concentration_points = clamp(
		concentration_points - cp_delta_por_jogador[jogador],
		0,
		100
	)
	
	cp_delta_por_jogador.erase(jogador)

func aplicar_concentration_temporario(jogador: String, valor: int) -> void:
	concentration_points = clamp(concentration_points + valor, 0, 100)
	cp_delta_por_jogador[jogador] = cp_delta_por_jogador.get(jogador, 0) + valor

func end_batalha(enemie: bool = true) -> void:
	if entityManager.enemiesNodes.size() > 0 and enemie: return
	#await get_tree().create_timer(2.0).timeout
	Manager.tocar_musica(DataAudioPlayer.new())
	set_process(false)
	batalha.dungeons2D.terminar_batalha()
	Manager.Extras.EnemiesVistos.append(batalha.id)
	Manager.CurrentBatalha = null
	queue_free()

func dead_batalha() -> void:
	await get_tree().create_timer(0.0).timeout
	Manager.tocar_musica(DataAudioPlayer.new())
	set_process(false)
	Manager.Game_Over()
	Manager.Extras.EnemiesVistos.append(batalha.id)
	Manager.CurrentBatalha = null
	queue_free()

func add_concentration_points(value: int) -> void:
	concentration_points = clamp(concentration_points + value, 0.0, 100.0)
 
