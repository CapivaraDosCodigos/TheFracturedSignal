extends Panel
class_name PanelPlayer

@export var player: String

@onready var texture: TextureRect = %Texture
@onready var life: Label = %life

func _process(_delta: float) -> void:
	var playerNew: PlayerData = Manager.PlayersAtuais[player]
	life.text = str(playerNew.Life) + "/" + str(playerNew.maxlife)
