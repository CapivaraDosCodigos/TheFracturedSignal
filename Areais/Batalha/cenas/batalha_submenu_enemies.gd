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
	
func get_inimigo(inimigos_custom: Dictionary[int, EnemiesBase2D]) -> int:
	inimigos = inimigos_custom.values()
	if inimigos.is_empty():
		return -1
	
	ativo = true
	visible = true
	set_process_unhandled_input(true)
	current_index = 0
	
	_atualizar_inimigos()
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
		current_index = (current_index + 1) % inimigos.size()
		_focus_button()
	
	elif event.is_action_pressed("Up"):
		current_index = (current_index - 1 + inimigos.size()) % inimigos.size()
		_focus_button()
	
	elif event.is_action_pressed("confirm"):
		last_result = inimigos[current_index].id
		end()
	
	elif event.is_action_pressed("cancel"):
		last_result = -1
		end()

func _focus_button() -> void:
	if current_index >= 0 and current_index < buttaos.size() and buttaos[current_index].visible:
		await get_tree().process_frame
		buttaos[current_index].grab_focus()

func end() -> void:
	ativo = false
	visible = false

func _atualizar_inimigos() -> void:
	for b in buttaos:
		b.visible = false
	
	for i in range(min(inimigos.size(), buttaos.size())):
		var inim = inimigos[i]
		var btn = buttaos[i]
		
		btn.visible = true
		btn.nome.text = "%s - %d%%" % [inim.nome, inim.merce]
		btn.life.max_value = inim.maxlife
		btn.life.value = inim.life
