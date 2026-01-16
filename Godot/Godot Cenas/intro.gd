extends CanvasLayer
class_name CanvasLayerIntro

@onready var menus: Dictionary[String, SubMenuBase] = {
	"save": $MenuSaves,
	"sair": $Sair }
@onready var menu_saves: SubMenuBase = $MenuSaves
@onready var menu_sair: SubMenuBase = $Sair

func _ready() -> void:
	Manager.change_state("NOT_IN_THE_GAME")
	menu_saves.abrir()
	
	Manager.tocar_musica(PathsMusic.AUDIO_STORY, 1)
	Global.play_transition("end_transition")
	#var duracao: float = Global.play_transition("end_transition") + 0.1
	#await get_tree().create_timer(duracao).timeout

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("cancel"):
		if !menu_sair.ativo:
			menu_sair.abrir()
		#else:
			#menu_sair.fechar()
			#menu_saves.abrir()
