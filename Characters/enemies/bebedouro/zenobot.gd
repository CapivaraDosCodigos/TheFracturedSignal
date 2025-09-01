extends CharacterBody2D

@onready var RayChat := $RayCast

var pesos: Array = []
var neurônios: Array = []

var raynumber: int
var posX: int
var posY: int
var velX: int
var velY: int

@export var speed := 50
var direction: Vector2 = Vector2.ZERO
var last_facing := "Down"

func _ready():
	randomize()
	pesos.resize(36)
	neurônios.resize(8)
	for i in pesos.size():
		pesos[i] = randi_range(-1000, 1000)
		print(pesos[i])

func _process(delta: float) -> void:
	raynumber = true if RayChat.is_colliding() else false
	posX = int(position.x)
	posY = int(position.y)
	velX = int(velocity.x)
	velY = int(velocity.y)
	
	neurônio1(0,0)
	neurônio1(5,1)
	neurônio1(10,2)
	neurônio1(15,3)
	neurônio2(0, 19, 4)
	neurônio2(1, 23, 5)
	neurônio2(2, 27, 6)
	neurônio2(3, 31, 7)
		
	if neurônios[4] > neurônios[5]:
		if neurônios[4] > 0:
			direction.y = -1
	else:
		if neurônios[4] > 0:
			direction.y = 1
			
	if neurônios[6] > neurônios[7]:
		if neurônios[6] > 0:
			direction.x = -1
	else:
		if neurônios[7] > 0:
			direction.x = 1
			
	velocity = direction * speed
	move_and_slide()
	update_animation()
	
	if Input.is_action_just_pressed("menu"):
		randomizar_pesos()
	
func neurônio1(peso1: int, nel: int):
	var a = posX * pesos[peso1]
	var b = posY * pesos[peso1 + 1]
	var c = velX * pesos[peso1 + 2]
	var d = velY * pesos[peso1 + 3]
	var f = raynumber * pesos[peso1 + 4]
	var abcdf = a + b + c + d + f
	neurônios[nel] = abcdf if abcdf > 0 else 0
	
func neurônio2(neu1: int, peso1: int, nel: int):
	var a = neurônios[neu1] * pesos[peso1]
	var b = neurônios[neu1 + 1] * pesos[peso1 + 1]
	var c = neurônios[neu1 + 2] * pesos[peso1 + 2]
	var d = neurônios[neu1 + 3] * pesos[peso1 + 3]
	var abcd = a + b + c + d
	neurônios[nel] = abcd if abcd > 0 else 0
		
func update_animation():
	var anim_player = $Anim
					
	if direction != Vector2.ZERO:
							# Atualiza direção base
		if abs(direction.x) > abs(direction.y):
			last_facing = "Right" if direction.x > 0 else "Left"
		else:
			last_facing = "Down" if direction.y > 0 else "Up"
																																															
		anim_player.play("w_" + last_facing)
	else:
		anim_player.play("i_" + last_facing)
																																																																			
func randomizar_pesos():
	for i in pesos.size():
		pesos[i] = randi_range(-1000, 1000)
																																																																			
