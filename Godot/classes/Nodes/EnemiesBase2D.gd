class_name EnemiesBase2D extends AnimatedSprite2D

@export_group("GameEnemies")
@export var nome: String = "Enemie"

@export_group("EnemiesStarts")
@export var life: int = 30
@export var maxlife: int = 30
@export var strength: int = 1
@export var defense: int = 1
@export_range(0, 100, 1) var merce: float = 0
@export_range(0.0, 30.0, 0.1) var time: float = 5.0
@export var poupavel: bool = true

var rootbatalha: Batalha2D
var id: int = 0

func _process(_delta: float) -> void:
	if life <= 0:
		_dead()
		
	if merce >= 100:
		_poupado()

func _dead() -> void:
	rootbatalha.remover_inimigo(id)
	#play("dead")
	queue_free()

func _poupado() -> void:
	rootbatalha.remover_inimigo(id)
	#play("poupado")
	queue_free()

func atacar():
	#print(nome + " com preguisa")
	pass

func _on_animation_finished():
	if animation == "dead" and animation == "dead":
		queue_free()

func _to_string() -> String:
	return nome
