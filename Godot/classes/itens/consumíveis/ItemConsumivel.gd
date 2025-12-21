@icon("res://texture/folderTres/texturas/comida.tres")
class_name ItemConsumivel extends DataItem

enum Tipo { CuraHP, AumentaCP }

@export var cura: int = 50
@export var concentration: int = 0
@export var efeito: Tipo = Tipo.CuraHP

func usar(player: String) -> void:
	match efeito:
		Tipo.CuraHP:
			Manager.get_Player(player).Life += cura
	
		Tipo.AumentaCP:
			Manager.CurrentBatalha.add_concentration_points(25)
