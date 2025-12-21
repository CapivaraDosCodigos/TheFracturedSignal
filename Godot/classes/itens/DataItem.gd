@icon("res://texture/folderTres/texturas/item.tres")
class_name DataItem extends Resource

@export var nome: String = "Item Genérico"
@export var preco: int = 0
@export_multiline var descricao: String = ""
@export var icone: Texture2D
@export var inbatalha: bool = false
@export var need_player: bool = false

func _to_string() -> String:
	return nome

func usar(_value) -> void:
	print("o item %s foi usado" % [nome])
