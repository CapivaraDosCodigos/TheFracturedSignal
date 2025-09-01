class_name EnemiesBase extends Resource

@export_group("GameEnemies")
@export var nome: String = "enemies"
@export var Anime: SpriteFrames = SpriteFrames.new()
@export var MaterialI: ShaderMaterial = null

@export_group("EnemiesStarts")
@export var life: int = 30
@export var maxlife: int = 30
@export var strength: int = 1
@export var defense: int = 1
@export var time: float = 5.0

func _to_string() -> String:
	return nome + " " + str(life)

func atacar():
	print("preguisa")
