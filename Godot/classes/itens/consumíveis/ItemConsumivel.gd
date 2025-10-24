@icon("res://texture/folderTres/texturas/comida.tres")
class_name ItemConsumivel extends DataItem

enum Tipo { CuraHP, AumentaSP }

@export var cura: int = 50
@export var sp: int = 0


@export var efeito: Tipo = Tipo.CuraHP

func usar(player: String) -> void:
	if efeito == Tipo.CuraHP:
		print(player)
		Manager.PlayersAtuais[player].Life += cura
		
