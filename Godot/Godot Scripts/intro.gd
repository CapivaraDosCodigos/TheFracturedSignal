extends Control

const PATH_MUSIC: String = "res://sons/music/audio_story.ogg"

@onready var botoes: Array[Button] = [ %inicia1, %inicia2, %inicia3, %inicia4, %inicia5 ] 
@onready var botoesDelete: Array[Button] = [ %deletar, %deletar2, %deletar3, %deletar4, %deletar5 ]

var botaodelete: bool = false
var botao_index: int = 0

func _ready() -> void:
	Manager.tocar_musica(PATH_MUSIC, 80)
	#Manager.change_state(Manager.GameState.NOT_IN_THE_GAME)
	_atulizar()
	botoes[botao_index].grab_focus()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("Left"):
		botaodelete = false
		botoes[botao_index].grab_focus()
		
	elif event.is_action_pressed("Right"):
		if botoesDelete[botao_index].visible:
			botaodelete = true
			botoesDelete[botao_index].grab_focus()
		else:
			botaodelete = false
			botoes[botao_index].grab_focus()
		
	elif event.is_action_pressed("Down"):
		if not botaodelete:
			if not botao_index == botoes.size() - 1:
				botao_index = (botao_index + 1) % botoes.size()
				botoes[botao_index].grab_focus()
		else:
			if not botao_index == botoesDelete.size() - 1:
				botao_index = (botao_index + 1) % botoesDelete.size()
				if botoesDelete[botao_index].visible:
					botoesDelete[botao_index].grab_focus()
				else:
					botaodelete = false
					botoes[botao_index].grab_focus()
	
	elif event.is_action_pressed("Up"):
		if not botaodelete:
			if not botao_index == 0:
				botao_index = (botao_index - 1 + botoes.size()) % botoes.size()
				botoes[botao_index].grab_focus()
				
		else:
			if not botao_index == 0:
				botao_index = (botao_index - 1 + botoesDelete.size()) % botoesDelete.size()
				if botoesDelete[botao_index].visible:
					botoesDelete[botao_index].grab_focus()
				else:
					botaodelete = false
					botoes[botao_index].grab_focus()
	
	elif event.is_action_pressed("confirm"):
		if not botaodelete:
			botoes[botao_index].emit_signal("pressed")
		else:
			botoesDelete[botao_index].emit_signal("pressed")
			botoes[botao_index].grab_focus()

func _atulizar() -> void:
	for i in botoes.size():
		if not ResourceLoader.exists(Database.SAVE_PATH % (i + 1)):
			botoes[i].text = "Iniciar Sistema " + str(i + 1) + "*"
			botoesDelete[i].visible = false
		else:
			#botoes[i].text = "Volta Sistema " + str(i + 1) + "* " + SaveData.CarregarTime(i + 1)
			botoesDelete[i].visible = true
			botoes[i].text = SaveData.CarregarTemporada(i + 1) + " " + SaveData.CarregarTime(i + 1)

func _on_inicia_1_pressed() -> void:
	_start(1)

func _on_inicia_2_pressed() -> void:
	_start(2)

func _on_inicia_3_pressed() -> void:
	_start(3)

func _on_inicia_4_pressed() -> void:
	_start(4)

func _on_inicia_5_pressed() -> void:
	_start(5)

func _on_deletar_1_pressed() -> void:
	_deletar(1)

func _on_deletar_2_pressed() -> void:
	_deletar(2)

func _on_deletar_3_pressed() -> void:
	_deletar(3)

func _on_deletar_4_pressed() -> void:
	_deletar(4)

func _on_deletar_5_pressed() -> void:
	_deletar(5)

func _start(slot: int ) -> void:
	await get_tree().process_frame
	Manager.Start_Save(slot, 1)

func _deletar(slot: int) -> void:
	SaveData.Deletar(slot)
	_atulizar()
