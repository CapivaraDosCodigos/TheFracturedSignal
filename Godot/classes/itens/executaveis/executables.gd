extends Resource
class_name Executable

@export var Nome: String = ""

func executar() -> void:
	print("voce usou %s" % [Nome])
