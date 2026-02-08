extends SubMenuBase

@onready var botoes: Array[ButtonUI] = [ %inicia1, %inicia2, %inicia3, %inicia4, %inicia5 ] 
@onready var botoesDelete: Array[ButtonUI] = [ %deletar, %deletar2, %deletar3, %deletar4, %deletar5 ]


func _on_opened() -> void:
	_atulizar()
	botoes[0].grab_focus()

func _atulizar() -> void:
	for i in botoes.size():
		if not ResourceLoader.exists(Database.SAVE_PATH % (i + 1)):
			botoes[i].text = "Iniciar Sistema " + str(i + 1) + "*"
			botoesDelete[i].visible = false
		else:
			botoesDelete[i].visible = true
			botoes[i].text = SaveData.CarregarCampo(i + 1, "nome") + " " + SaveData.CarregarCampo(i + 1, "TimeSave")

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

func _start(slot: int) -> void:
	Manager.tocar_musica(PathsMusic.INTRO_1)
	var duracao: float = Global.play_transition("start_transition")
	await get_tree().create_timer(duracao).timeout
	Manager.Start_Save(slot, 1)

func _deletar(slot: int) -> void:
	Manager.tocar_musica(PathsMusic.CANCEL, 2)
	SaveData.Deletar(slot)
	_atulizar()
