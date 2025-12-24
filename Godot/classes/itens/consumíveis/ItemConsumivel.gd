@icon("res://texture/folderTres/texturas/comida.tres")
class_name ItemConsumivel extends DataItem

enum Tipo { CuraHP, CuraMAX, CuraMIN, AumentaCP }

@export var cura: int = 50
@export var concentration: int = 0
@export var efeito: Tipo = Tipo.CuraHP

func usar(player: String) -> void:
	match efeito:
		Tipo.CuraHP:
			Manager.get_Player(player).Life += cura
	
		Tipo.CuraMAX:
			Manager.get_Player(player).reset() 
	
		Tipo.CuraMIN:
			var LocalPlayer: PlayerData = Manager.get_Player(player)
			if LocalPlayer.Life + cura >= LocalPlayer.maxlife:
				LocalPlayer.reset()
			else:
				LocalPlayer.Life += cura
	
		Tipo.AumentaCP:
			Manager.CurrentBatalha.add_concentration_points(concentration)
