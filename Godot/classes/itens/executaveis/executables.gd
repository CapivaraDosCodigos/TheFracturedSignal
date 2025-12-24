extends Resource
class_name Executable

enum TIPO { DanoNormal }
enum NEED { None, Player, Enemie }

@export_group("Visual")
@export var Nome: String = ""
@export var icone: Texture2D
@export_multiline var descricao: String = ""

@export_group("Especifcaçoes")
@export var efeito: TIPO = TIPO.DanoNormal
@export var needs: NEED = NEED.None
@export var player: String = ""

@export_subgroup("Preços", "preco")
@export var preco_HP: int = 0
@export var preco_CP: int = 0

@export_subgroup("Valores")
@export var dano: int = 0
@export var cura: int = 0

func executar() -> void:
	print("voce usou %s" % [Nome])

func get_disponivel() -> bool:
	if Manager.get_Player(player).Life < preco_HP:
		return false
	
	if Manager.CurrentBatalha.concentration_points < preco_CP:
		return false
	
	return true

func coprando() -> void:
	Manager.CurrentBatalha._aplicar_concentration_temporario(player, preco_CP * -1)
	
