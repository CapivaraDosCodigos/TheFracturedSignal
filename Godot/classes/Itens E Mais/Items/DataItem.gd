@icon("res://Resources/texturas/item.tres")
class_name DataItem extends Resource

@export_group("Visual")
@export var nome: String = "Item Genérico"
@export var icone: Texture2D
@export_multiline var descricao: String = ""

@export_group("")
@export var preco: int = 0
@export var inBatalha: bool = false
@export var inMenu: bool = false
@export var need_player: bool = false

func _to_string() -> String:
	return nome

func usar(_value) -> void:
	print("o item %s foi usado" % [nome])
