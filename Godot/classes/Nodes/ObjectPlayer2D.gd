## Classe responsável por controlar o Player principal e os seguidores no estilo Deltarune.
## O mesmo script funciona tanto para o personagem controlado pelo jogador quanto para os "followers".
class_name ObjectPlayer2D
extends CharacterBody2D

## Velocidade base do personagem.
@export var speed: float = 70.0
## Define se este objeto NÃO é o player principal (ou seja, será um seguidor).
@export var no_player: bool = false
## Nome
@export var Nome: String

@export_group("Velocidades")
## Multiplicador de velocidade ao correr.
@export var speed_running: float = 1.5
## Multiplicador de velocidade ao andar.
@export var speed_walk: float = 1.0

@export_group("Amimaçoes")
## Velocidade das animações ao correr.
@export var anim_running: float = 1.5
## Velocidade das animações ao andar.
@export var anim_walk: float = 1.0

@export_group("Nodes")
## Referência ao AnimationPlayer que controla as animações.
@export var anim_player: AnimationPlayer
## RayCast usado para detectar colisões à frente.
@export var RayChat: RayCast2D
## Referência ao líder (outro ObjectPlayer) caso este seja um seguidor.
@export var leader: ObjectPlayer2D
## A camera do jogo em cada personagem.
@export var can: Node2D
## A área do player.
@export var area: Area2D

## Direção atual do movimento.
var direction: Vector2 = Vector2.ZERO

## Última direção em que o personagem estava virado (para animações).
var last_facing: String = "Down"

## Multiplicador de velocidade atual.
var running: float = 1.0

## Flag que indica se o personagem está parado por colidir com uma área especial.
var stopped_by_area: bool = false

## Array que armazena as posições do player para gerar a "trilha" que os seguidores usam.
var trail: Array[Vector2] = []

## Quantidade máxima de posições que serão mantidas na trilha.
@export var trail_length: int = 20

func _ready() -> void:
	await get_tree().process_frame
	area.area_entered.connect(_on_area_2d_area_entered)
	area.area_exited.connect(_on_area_2d_area_exited)

func _process(_delta: float) -> void:
	if Manager.current_status == Manager.GameState.MAP:
		if Starts.Current_player != null and Starts.Current_player.has_method("update_properties"):
			no_player = not (Starts.Current_player.Nome == Nome)
			
		player_physics()
		follower_physics()
	
	elif Manager.current_status == Manager.GameState.DIALOGUE:
		update_animation(Vector2.ZERO)

## Física do player controlado pelo usuário.
func player_physics() -> void:
	if no_player:
		return
		
	if can.has_method("set_priority"):
		can.priority = 10
	#
	if Manager.Menu.menu:
		update_animation(Vector2.ZERO)
		return
	
	Manager.raio = RayChat
	
	var _is_running := Input.is_action_pressed("cancel")
	direction = _input_direction()
	
	running = speed_running if _is_running else speed_walk
	anim_player.speed_scale = anim_running if _is_running else anim_walk
	
	velocity = direction * speed * running
	move_and_slide()
	update_animation(direction)
	
	trail.push_front(global_position)
	if trail.size() > trail_length:
		trail.pop_back()

## Física de um seguidor (segue o líder pela trilha).
func follower_physics() -> void:
	if not no_player:
		return
		
	if can.has_method("set_priority"):
		can.priority = 0
	
	if leader == null:
		return
	
	var _is_running := Input.is_action_pressed("cancel")
	anim_player.speed_scale = anim_running if _is_running else anim_walk
	running = speed_running if _is_running else speed_walk
	
	if stopped_by_area:
		velocity = Vector2.ZERO
		update_animation(Vector2.ZERO)
		move_and_slide()
		return
	
	if RayChat.is_colliding() and RayChat.get_collider() == leader:
		velocity = Vector2.ZERO
		update_animation(Vector2.ZERO)
		move_and_slide()
		return
	
	if leader.trail.size() < trail_length:
		velocity = Vector2.ZERO
		update_animation(Vector2.ZERO)
		move_and_slide()
		return
	
	var target_pos = leader.trail.back()
	var dir = (target_pos - global_position).normalized()
	velocity = dir * speed * running
	move_and_slide()
	update_animation(dir)
	
	trail.push_front(global_position)
	if trail.size() > trail_length:
		trail.pop_back()

## Atualiza a animação de acordo com a direção atual.
func update_animation(_dir: Vector2) -> void:
	if _dir != Vector2.ZERO:
		if abs(_dir.x) > abs(_dir.y):
			last_facing = "Right" if _dir.x > 0 else "Left"
		else:
			last_facing = "Down" if _dir.y > 0 else "Up"
		anim_player.play("w_" + last_facing)
	else:
		anim_player.play("i_" + last_facing)

## Calcula a direção a partir das teclas de movimento.
func _input_direction() -> Vector2:
	return Vector2(
		Input.get_action_strength("Right") - Input.get_action_strength("Left"),
		Input.get_action_strength("Down") - Input.get_action_strength("Up")
	).normalized()

## Callback chamado quando entra em uma área especial → para o movimento.
func _on_area_2d_area_entered(_area: Area2D) -> void:
	if not leader == null:
		if leader.area == _area:
			stopped_by_area = true

## Callback chamado quando sai de uma área especial → retoma o movimento.
func _on_area_2d_area_exited(_area: Area2D) -> void:
	if not leader == null:
		if leader.area == _area:
			stopped_by_area = false
