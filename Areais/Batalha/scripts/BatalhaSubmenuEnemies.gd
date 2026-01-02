extends PanelContainer
class_name BatalhaSubmenuEnemies

@onready var buttaos: Array[InimigoButton] = [ %Inimigo1, %Inimigo2, %Inimigo3 ]

var inimigos: Array[EnemiesBase2D] = []
var current_index: int = 0
var ativo: bool = false
var last_result: int = -1

func _ready() -> void:
	visible = false
	current_index = 0
	set_process_unhandled_input(false)

func get_inimigo() -> int:
	if inimigos.is_empty():
		return -1
	
	ativo = true
	visible = true
	set_process_unhandled_input(true)
	current_index = 0
	
	_focus_button()

	while ativo:
		await get_tree().process_frame
	
	set_process_unhandled_input(false)
	var result = last_result
	last_result = -1
	return result

func _unhandled_input(event: InputEvent) -> void:
	if not ativo:
		return
	
	if event.is_action_pressed("Down"):
		Manager.tocar_musica(PathsMusic.MODERN_3, 2)
		current_index = (current_index + 1) % inimigos.size()
		_focus_button()
	
	elif event.is_action_pressed("Up"):
		Manager.tocar_musica(PathsMusic.MODERN_3, 2)
		current_index = (current_index - 1 + inimigos.size()) % inimigos.size()
		_focus_button()
	
	elif event.is_action_pressed("confirm"):
		Manager.tocar_musica(PathsMusic.MODERN_9, 3)
		last_result = inimigos[current_index].id
		end()
	
	elif event.is_action_pressed("cancel"):
		Manager.tocar_musica(PathsMusic.CANCEL, 3)
		last_result = -1
		end()

func _focus_button() -> void:
	if current_index >= 0 and current_index < buttaos.size() and buttaos[current_index].visible:
		await get_tree().process_frame
		buttaos[current_index].grab_focus()

func end() -> void:
	ativo = false
	visible = false

func atualizar_inimigos(inimigos_custom: Dictionary[int, EnemiesBase2D]) -> void:
	inimigos = inimigos_custom.values()
	for b in buttaos:
		b.visible = false
	
	for i in range(min(inimigos.size(), buttaos.size())):
		var inim = inimigos[i]
		var btn = buttaos[i]
		
		btn.visible = true
		btn.nome.text = "%s - %d%%" % [inim.nome, inim.merce]
		btn.life.max_value = inim.maxlife
		btn.life.value = inim.life
