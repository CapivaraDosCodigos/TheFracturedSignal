extends SubMenuBase

@onready var container_buttons: VBoxContainer = $MarginContainer/PanelItems/ContainerButtons
@onready var container_sons: VBoxContainer = $MarginContainer/PanelItems/ContainerSons
@onready var container_tela: VBoxContainer = $MarginContainer/PanelItems/ContainerTela
@onready var voltar_ao_titulo: ButtonUI = %VoltarAoTitulo
@onready var musica: HSliderUI = %musica
@onready var efeitos_sonoros: HSliderUI = %EfeitosSonoros
@onready var fps: CheckBoxUI = %FPS

var sincronizando: bool = false

func _on_opened() -> void:
	container_buttons.visible = true
	container_sons.visible = false
	container_tela.visible = false
	voltar_ao_titulo.grab_focus()

func _on_closed() -> void:
	container_buttons.visible = true
	container_sons.visible = false
	container_tela.visible = false

func _on_voltar_ao_titulo_pressed() -> void:
	var duracao: float = Global.play_transition("start_transition")
	await get_tree().create_timer(duracao).timeout
	Manager.Return_To_Title()

func _on_sons_pressed() -> void:
	sincronizando = true
	
	musica.value = Global.musica
	efeitos_sonoros.value = Global.efeito
	
	await get_tree().process_frame
	
	sincronizando = false
	container_buttons.visible = false
	container_sons.visible = true
	container_tela.visible = false
	musica.grab_focus()

func _on_tela_pressed() -> void:
	fps.button_pressed = Global.configures.fps_bool
	
	await get_tree().process_frame
	
	container_buttons.visible = false
	container_sons.visible = false
	container_tela.visible = true
	fps.grab_focus()

func _on_musica_value_changed(value: float) -> void:
	if sincronizando:
		return
	Global.musica = value

func _on_efeitos_sonoros_value_changed(value: float) -> void:
	if sincronizando:
		return
	Global.efeito = value

func _on_fps_pressed() -> void:
	Global.configures.fps_bool = fps.button_pressed
