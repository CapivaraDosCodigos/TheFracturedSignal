class_name Datas extends Resource

## ID da cena que será carregada (índice ou código de referência).
@export var id: int = 0

## Construtor da classe GlobalData.
## @param _id ID da cena inicial.
func _init(_id: int = 0) -> void:
	id = _id

## Retorna uma string representando o estado atual.
func _to_string() -> String:
	return "id = " + str(id)
