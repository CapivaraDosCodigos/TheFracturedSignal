@icon("res://Resources/texturas/item.tres")
class_name DataItem extends Resource

@export var preco: int = 0
@export var inBatalha: bool = false
@export var inMenu: bool = false
@export var need_player: bool = false

@export_category("Visual")
@export var nome: String = "Item Genérico"
@export var icone: Texture2D
@export_multiline var descricao: String = ""


func _to_string() -> String:
	return nome

func usar(_value) -> void:
	print("o item %s foi usado" % [nome])
