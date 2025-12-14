extends Button
class_name InimigoButton

@onready var nome: Label = %Nome
@onready var life: ProgressBar = %Life
@onready var life_label: Label = %LifeLabel
@onready var texture_rect: TextureRect = $MarginContainer/VBoxContainer/TextureRect

func _process(_delta: float) -> void:
	texture_rect.visible = has_focus()
