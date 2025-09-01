# DataItem.gd
class_name DataItem extends Resource

@export var nome: String = "Item Genérico"
@export var uid: int = 0
@export var preco: int = 0
@export var descricao: String = ""
@export var icone: Texture2D

func _to_string() -> String:
	return nome
	
