extends Node

const GLOBAl_PATH: String = "user://configures.tres"

var configures: DataConf = DataConf.new()

func _ready() -> void:
	Carregar_Arquivo()

func Carregar_Arquivo() -> DataConf:
	if not ResourceLoader.exists(GLOBAl_PATH):
		return DataConf.new()
	
	var conf = ResourceLoader.load(GLOBAl_PATH)
	return conf

func Salvar_Arquivo() -> void:
	var err := ResourceSaver.save(configures, GLOBAl_PATH)
	if err != OK:
		push_error("❌ Falha ao salvar. Código de erro: %s" % [err])
	else:
		print("💾 Dados salvos")
