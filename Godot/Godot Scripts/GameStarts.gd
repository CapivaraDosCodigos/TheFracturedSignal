extends Node

var Data: GlobalData; var InvData: Inventory = Inventory.new(); var Conf: DataConf; var InfDatas: DataExtras; var Current_player: PlayerData
var Pdir: Dictionary[String, PlayerData]
var Current_scene: PackedScene

var InGame: bool = false

func _ready() -> void:
	SaveData.Deletar(1, SaveData.TIPO_DATAS.Global)
	Start_Save(1)

func SAVE(slot: int) -> void:
	# Atualiza o objeto salvo 
	Data.Inv = InvData
	Data.CharDir = Pdir
	Data.current_player = Current_player
	Data.Conf = Conf
	Data.Datas = InfDatas
	
	SaveData.Salvar(slot, Data, SaveData.TIPO_DATAS.Global)

func Start_Save(slot: int) -> void:
	if not is_inside_tree():
		await get_tree().process_frame
	
	Data = SaveData.Carregar(slot, SaveData.TIPO_DATAS.Global)
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

func _process(_delta: float) -> void:
	pass
	#if InGame:
		#return
	#
	#for personagem in Pdir.values():
		#personagem.update_properties(InvData)
	#Pdir["Zeno"].update_properties(InvData)
	#Pdir["Niko"].update_properties(InvData)
	
