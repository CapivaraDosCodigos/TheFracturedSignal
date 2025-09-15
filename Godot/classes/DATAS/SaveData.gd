class_name SaveData extends Resource

const save_path: String = Database.SAVE_PATH
const total_slot: int = Database.TOTAL_SLOTS

static func Carregar(slot: int) -> GlobalData:
	if not _is_slot_valid(slot):
		push_warning("erro slot invalido")
		return null
	
	var path := save_path % slot
	if not ResourceLoader.exists(path):
		return GlobalData.new()
	
	var loaded_data = ResourceLoader.load(path)
	return loaded_data

static func Carregar_Arquivo(caminho: String) -> GlobalData:
	if not ResourceLoader.exists(caminho):
		push_warning("📂 Arquivo não encontrado: " + caminho)
		return null
	
	var loaded_data = ResourceLoader.load(caminho)
	return loaded_data

static func Salvar(slot: int, origem: GlobalData) -> void:
	if not _is_slot_valid(slot): return

	var path := save_path % slot
	var err := ResourceSaver.save(origem, path)
	if err != OK:
		push_error("❌ Falha ao salvar slot %d. Código de erro: %s" % [slot, err])
	else:
		print("💾 Dados salvos no slot %d." % slot)

static func Deletar(slot: int) -> void:
	if not _is_slot_valid(slot): return
	
	var path := save_path % slot
	if FileAccess.file_exists(path):
		OS.move_to_trash(ProjectSettings.globalize_path(path))

static func _is_slot_valid(slot: int) -> bool:
	if slot < 1 or slot > total_slot:
		push_error("❌ Slot inválido: %d" % slot)
		return false
	return true
