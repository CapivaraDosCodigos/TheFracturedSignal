extends Node

var Data: SeasonResource
var Extras: DataExtras

var CurrentScene: PackedScene
var CurrentPlayer: PlayerData
var CurrentInventory: Inventory

var CurrentPlayerString: String

var PlayersAtuais: Dictionary[String, PlayerData]

var InGame: bool = false

func _ready() -> void:
	Start_Save(1)

#func _process(_delta: float) -> void:
	#if InGame:
		#return
	#
	#_atualisar_propriedades()

func SAVE(slot: int) -> void:
	Data.Extras = Extras
	Data.CurrentScene = CurrentScene
	Data.CurrentPlayer = CurrentPlayerString
	Data.CurrentInventory = CurrentInventory
	Data.PlayersAtuais = PlayersAtuais
	Data.slot = slot
	
	SaveData.Salvar(slot, Data)

func Start_Save(slot: int) -> void:
	if not is_inside_tree():
		await get_tree().process_frame
	
	Data = SaveData.Carregar_Arquivo("res://Godot/classes/DATAS/test.tres")
	Extras = Data.Extras
	CurrentScene = Data.CurrentScene
	CurrentPlayerString = Data.CurrentPlayer
	CurrentInventory = Data.CurrentInventory
	PlayersAtuais = Data.PlayersAtuais
	slot = Data.slot
	
	_atualisar_propriedades()
	#get_tree().change_scene_to_packed(CurrentScene)
	InGame = true

func Return_To_Title() -> void:
	await get_tree().process_frame
	Data = null
	Extras = null
	CurrentScene = null
	CurrentInventory = null
	CurrentPlayer = null
	CurrentPlayerString = ""
	CurrentInventory = null
	PlayersAtuais.clear()
	
	get_tree().change_scene_to_file("res://Godot/Godot Cenas/intro.tscn")

func IsCurrentPlayer(player: PlayerData) -> void:
	AdicionarPlayer(player)
	CurrentPlayer = player

func AdicionarPlayer(player: PlayerData) -> void:
	if not PlayersAtuais.has(player.Nome):
		PlayersAtuais[player.Nome] = player

func RemoverPlayer(player: String) -> void:
	if PlayersAtuais.has(player):
		PlayersAtuais.erase(player)

func Dead() -> void:
	pass

func InGameIsTrue() -> void:
	while not InGame:
		await get_tree().process_frame

func _atualisar_propriedades():
	#CurrentPlayer = PlayersAtuais[CurrentPlayerString]
	if PlayersAtuais.has(CurrentPlayerString):
		CurrentPlayer = PlayersAtuais[CurrentPlayerString]
	else:
		push_error("Chave '%s' não existe em PlayersAtuais" % CurrentPlayerString)
	
	for key in PlayersAtuais.keys():
		PlayersAtuais[key].update_properties()
