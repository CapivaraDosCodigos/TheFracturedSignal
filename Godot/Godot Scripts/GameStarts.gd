extends Node

var Data: GlobalData
var Conf: DataConf
var Extras: DataExtras

var CurrentScene: PackedScene
var CurrentPlayer: PlayerData
var CurrentInventory: Inventory

var CurrentPlayerString: String
var CurrentInventoryString: String
var PlayersAtuaisString: Array[String]

var PlayersAtuais: Dictionary[String, PlayerData]
var AllPlayers: Dictionary[String, PlayerData]
var AllInventory: Dictionary[String, Inventory]

var InGame: bool = false

func _ready() -> void:
	Start_Save(1)

func _process(_delta: float) -> void:
	if InGame:
		return
		
	atualisar(true)
	
func SAVE(slot: int) -> void:
	Data.Conf = Conf
	Data.Extras = Extras
	Data.CurrentScene = CurrentScene
	Data.CurrentPlayer = CurrentPlayerString
	Data.CurrentInventory = CurrentInventoryString
	Data.PlayersAtuais = PlayersAtuaisString
	Data.AllInventory = AllInventory
	Data.AllPlayers = AllPlayers
	Data.slot = slot
	
	SaveData.Salvar(slot, Data)

func Start_Save(slot: int) -> void:
	if not is_inside_tree():
		await get_tree().process_frame
	
	Data = SaveData.Carregar_Arquivo("res://Godot/classes/DATAS/test.tres")
	Conf = Data.Conf
	Extras = Data.Extras
	CurrentScene = Data.CurrentScene
	CurrentPlayerString = Data.CurrentPlayer
	CurrentInventoryString = Data.CurrentInventory
	PlayersAtuaisString = Data.PlayersAtuais
	AllInventory = Data.AllInventory
	AllPlayers = Data.AllPlayers
	slot = Data.slot
	
	atualisar(false)
	#get_tree().change_scene_to_packed(CurrentScene)
	InGame = true

func Return_To_Title() -> void:
	await get_tree().process_frame
	Data = null
	Conf = null
	Extras = null
	CurrentScene = null
	CurrentInventory = null
	CurrentPlayer = null
	CurrentPlayerString = ""
	CurrentInventoryString = ""
	PlayersAtuais.clear()
	AllInventory.clear()
	AllPlayers.clear()
	
	get_tree().change_scene_to_file("res://Godot/Godot Cenas/intro.tscn")

func IsCurrentPlayer(player: String) -> void:
	AdicionarPlayer(player)
	CurrentPlayerString = player

func AdicionarPlayer(player: String) -> void:
	if not PlayersAtuais.has(player):
		PlayersAtuaisString.append(player)

func RemoverPlayer(player: String) -> void:
	if PlayersAtuais.has(player):
		PlayersAtuais.erase(player)

func Dead() -> void:
	pass

func InGameIsTrue() -> void:
	while not InGame:
		await get_tree().process_frame

func atualisar(booleana: bool):
	CurrentInventory = AllInventory[CurrentInventoryString]
	CurrentPlayer = AllPlayers[CurrentPlayerString]

	for nome in PlayersAtuaisString:
		if AllPlayers.has(nome):
			var personagem = AllPlayers[nome]
			PlayersAtuais[nome] = AllPlayers[nome]
			if booleana:
				personagem.update_properties(CurrentInventory)
