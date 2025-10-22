@icon("res://texture/folderTres/texturas/item.tres")
class_name DataItem extends Resource

@export var nome: String = "Item Genérico"
@export var preco: int = 0
@export var descricao: String = ""
@export var icone: Texture2D
@export var inbatalha: bool = false

func _to_string() -> String:
	return nome

func usar(_null) -> void:
	pass
