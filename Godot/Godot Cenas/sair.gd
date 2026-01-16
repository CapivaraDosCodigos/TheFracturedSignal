extends SubMenuBase

@onready var voltar: ButtonUI = %Voltar
@onready var intro: CanvasLayerIntro

func _ready() -> void:
	intro = get_parent()

func _on_opened() -> void:
	voltar.grab_focus()

func _on_voltar_pressed() -> void:
	intro.menu_saves._on_opened()
	fechar()

func _on_sair_pressed() -> void:
	Global.Salvar_Arquivo()
	get_tree().quit()
