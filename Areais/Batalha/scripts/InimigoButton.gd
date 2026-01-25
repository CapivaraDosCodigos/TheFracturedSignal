extends Button
class_name InimigoButton

@onready var nome: Label = %Nome
@onready var life: ProgressBar = %Life
@onready var life_label: Label = %LifeLabel
@onready var texture_rect: TextureRect = $MarginContainer/VBoxContainer/TextureRect

func _process(_delta: float) -> void:
	texture_rect.visible = has_focus()
	if has_focus() and !Manager.isState("NOT_IN_THE_GAME"):
		_atualizar_cor_icon()
	life_label.text = "%d/%d" % [life.value, life.max_value]

func _atualizar_cor_icon() -> void:
	if Manager.isState("NOT_IN_THE_GAME"):
		modulate = Color.WHITE
		return

	var player: PlayerData = Manager.get_Player()
	match player.Soul:
		PlayerData.Souls.Empty:
			texture_rect.modulate = Color.WHITE
	
		PlayerData.Souls.Hope:
			texture_rect.modulate = Color(0.561, 0.494, 0.816)

		_:
			texture_rect.modulate = Color.WHITE
