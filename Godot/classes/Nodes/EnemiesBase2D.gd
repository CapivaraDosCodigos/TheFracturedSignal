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
		poupado()

func _ready() -> void:
	animation_finished.connect(_on_animation_finished)

func _dead() -> void:
	rootbatalha.remover_inimigo(id)
	rootbatalha.end_batalha()
	$AnimatedSprite2D.play("default")
	await get_tree().create_timer(0.4).timeout
	queue_free()

func poupado() -> void:
	rootbatalha.remover_inimigo(id)
	rootbatalha.end_batalha()
	#play("poupado")
	queue_free()

func atacar() -> void:
	#print(nome + " com preguisa")
	pass

func _on_animation_finished() -> void:
	if animation == "dead" and animation == "dead":
		queue_free()

func _to_string() -> String:
	return nome

func apply_damage(dano_base: int) -> void:
	var reducao = defense / (defense + 1.0)
	var dano_final = int(dano_base * (1.0 - reducao))
	life -= dano_final
