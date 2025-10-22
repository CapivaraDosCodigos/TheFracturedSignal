@icon("res://texture/folderTres/texturas/comida.tres")
class_name ItemConsumivel extends DataItem

@export var cura: int = 50
@export var sp: int = 0

@export_enum("Cura HP", "Aumenta SP") var efeito: String = "Cura HP"

func usar(player: String = "") -> void:
	if efeito == "Cura HP":
		Manager.PlayersAtuais[player].Life += cura
		
		
	
