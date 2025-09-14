extends Node

var Data: GlobalData; var Conf: DataConf; var InfDatas: DataExtras; var Current_player: PlayerData
var Pdir: Dictionary[String, PlayerData]
var Current_scene: PackedScene

var InvData: Inventory = Inventory.new();

var InGame: bool = false

func _ready() -> void:
	SaveData.Deletar(1)
	Start_Save(1)

func SAVE(slot: int) -> void:
	Data.Inv = InvData
	Data.CharDir = Pdir
	Data.current_player = Current_player
	Data.Conf = Conf
	Data.Datas = InfDatas
	
	SaveData.Salvar(slot, Data)

func Start_Save(slot: int) -> void:
	if not is_inside_tree():
		await get_tree().process_frame
	
	Data = SaveData.Carregar(slot)
	InvData = Data.Inv
	Pdir = Data.CharDir
	Current_player = Data.current_player
	Current_scene = Database.SAVES_SCENE[Data.id]
	Conf = Data.Conf
	InfDatas = Data.DataE
	
	if typeof(Data.id) != TYPE_INT:
		push_error("❌ ID inválido no save: %s" % str(Data.id))
		return
		
	#get_tree().change_scene_to_packed(SAVES_SCENE[Data.id])
	print("slot ", slot, " foi iniciado em ", Data.id)
	InGame = true

func Return_To_Title() -> void:
	await get_tree().process_frame
	Data = null
	InvData = null
	Pdir.clear()
	Current_player = null
	Conf = null
	InfDatas = null
	InGame = false
	get_tree().change_scene_to_file("res://Godot/Godot Cenas/intro.tscn")

func Dead() -> void:
	pass

func InGameIsTrue() -> void:
	while not InGame:
		await get_tree().process_frame

func _process(_delta: float) -> void:
	if InGame:
		return
	
	for personagem in Pdir.values():
		personagem.update_properties(InvData)
	#Pdir["Zeno"].update_properties(InvData)
	#Pdir["Niko"].update_properties(InvData)
