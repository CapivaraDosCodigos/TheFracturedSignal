class_name EnemiesBase2D extends AnimatedSprite2D

@export_group("GameEnemies")
@export var nome: String = "Enemie"

@export_group("EnemiesStarts")
@export var life: int = 30
@export var maxlife: int = 30
@export_range(0, 100, 1) var merce: float = 0
@export_range(0.0, 30.0, 0.1) var time: float = 5.0
@export var poupavel: bool = true

@export_group("nodes")
@export var spawns: Array[SpawnProjeteis]

var rootobjeto: Node2D
var rootbatalha: Batalha2D
var id: int = 0

func _process(_delta: float) -> void:
	if life <= 0:
		_dead()
		
	if merce >= 100:
		poupado()

func _ready() -> void:
	animation_finished.connect(_on_animation_finished)
	play("idle")

func _dead() -> void:
	life = 0
	rootbatalha.remover_inimigo(id)
	play("Dead")

func poupado() -> void:
	rootbatalha.remover_inimigo(id)
	#play("poupado")
	queue_free()

func atacar() -> void:
	play("Attack")
	if not spawns.is_empty():
		spawns.pick_random().spawn(rootobjeto, time)

func apply_damage(dano: int) -> void:
	life -= dano

func _on_animation_finished() -> void:
	if animation == "Dead" or animation == "Spared":
		queue_free()
		
	elif animation == "Attack":
		play("idle")

func _to_string() -> String:
	return nome
