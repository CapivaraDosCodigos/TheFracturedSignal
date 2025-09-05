extends Control
class_name SubMenuBase

var ativo: bool = false

# Chamar isso quando o menu principal abrir esse submenu
func abrir() -> void:
	visible = true
	ativo = true
	_on_opened()

# Chamar isso quando o submenu for fechado (via cancel ou fim)
func fechar() -> void:
	_on_closed()
	visible = false
	ativo = false

# Subclasses podem sobrescrever isso se precisarem inicializar coisas
func _on_opened() -> void:
	pass

# Subclasses podem sobrescrever isso se precisarem limpar coisas
func _on_closed() -> void:
	pass
