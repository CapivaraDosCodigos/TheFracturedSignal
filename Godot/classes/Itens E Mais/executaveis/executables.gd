extends Resource
class_name Executable

enum TIPO { DanoNormal, DanoEmArea, CuraHP, CuraMAX, CuraMIN }
enum NEED { None, Player, Enemie }

@export_enum("Nome", "Zeno", "Niko") var Character: String = "Zeno"
@export var efeito: TIPO = TIPO.DanoNormal
@export var needs: NEED = NEED.None

@export_group("Preços", "preco")
@export var preco_HP: int = 0
@export var preco_CP: int = 0

@export_group("Valores")
@export var dano: int = 0
@export var cura: int = 0

@export_category("Visual")
@export var Nome: String = ""
@export var icone: Texture2D
@export_multiline var descricao: String = ""

func executar(propriedades: Dictionary) -> void:
	if !Manager.CurrentBatalha:
		return
	
	print("voce usou %s" % [Nome])
	match needs:
		NEED.None:
			_executar_None()
			
		NEED.Player:
			_executar_Player(propriedades["player"])
			
		NEED.Enemie:
			_executar_Enemie(propriedades["inimigo"])

func get_disponivel() -> bool:
	if Manager.get_Player(Character).Life >= preco_HP:
		return true
	
	if Manager.CurrentBatalha.concentration_points >= preco_CP:
		return true
	
	return false

func coprando() -> void:
	Manager.CurrentBatalha.aplicar_concentration_temporario(Character, preco_CP * -1)
	Manager.get_Player(Character).Life -= preco_HP

func _executar_None() -> void:
	match efeito:
		TIPO.CuraHP:
			Manager.get_Player(Character).Life += cura
	
		TIPO.CuraMAX:
			Manager.get_Player(Character).reset() 
	
		TIPO.CuraMIN:
			var LocalPlayer: PlayerData = Manager.get_Player(Character)
			if LocalPlayer.Life + cura >= LocalPlayer.maxlife:
				LocalPlayer.reset()
			else:
				LocalPlayer.Life += cura
	
		TIPO.DanoEmArea:
			var Batalha: Batalha2D = Manager.CurrentBatalha
			for inimigo: EnemiesBase2D in Batalha.enemiesNodes.values():
				inimigo.apply_damage(dano)
	
		_:
			printraw("mal configuraçao")

func _executar_Player(player: String) -> void:
	match efeito:
		TIPO.CuraHP:
			Manager.get_Player(player).Life += cura
	
		TIPO.CuraMAX:
			Manager.get_Player(player).reset() 
	
		TIPO.CuraMIN:
			var LocalPlayer: PlayerData = Manager.get_Player(player)
			if LocalPlayer.Life + cura >= LocalPlayer.maxlife:
				LocalPlayer.reset()
			else:
				LocalPlayer.Life += cura
	
		_:
			printraw("mal configuraçao")

func _executar_Enemie(inimigoIndex: int) -> void:
	match efeito:
		TIPO.DanoNormal:
			var Batalha: Batalha2D = Manager.CurrentBatalha
			var inimigo = Batalha.enemiesNodes.get(inimigoIndex, null)
			if inimigo != null:
				inimigo.apply_damage(dano)
				
		TIPO.DanoEmArea:
			var Batalha: Batalha2D = Manager.CurrentBatalha
			for inimigo: EnemiesBase2D in Batalha.enemiesNodes.values():
				inimigo.apply_damage(dano)
	
		_:
			printraw("mal configuraçao")
