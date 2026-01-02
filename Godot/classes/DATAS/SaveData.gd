@icon("res://Resources/texturas/globalsave.tres")
extends Resource
class_name SaveData

const total_slot: int = Database.TOTAL_SLOTS

static func Carregar(slot: int, temporada: int) -> SeasonResource:
	if not _is_slot_valid(slot):
		push_warning("⚠️ Slot inválido: %d" % slot)
		return null
	
	var path := Database.SAVE_PATH % slot
	if not FileAccess.file_exists(path):
		if temporada == 1:
			return GlobalSeasons.T1.duplicate_deep(Resource.DEEP_DUPLICATE_ALL)
		return null
	
	var loaded_data: SeasonResource = ResourceLoader.load(path)
	if loaded_data == null:
		push_error("❌ Falha ao carregar arquivo de save: " + path)
		return null
	
	prints_sizes(path)
	return loaded_data.duplicate_deep(Resource.DEEP_DUPLICATE_ALL)

static func CarregarCampo(slot: int, campo: String) -> Variant:
	if not _is_slot_valid(slot): return ""
	var path := Database.SAVE_PATH % slot
	if not FileAccess.file_exists(path): return ""
	var data: SeasonResource = ResourceLoader.load(path)
	if data == null:
		return ""
	return data.get(campo)

static func Salvar(slot: int, origem: SeasonResource) -> void:
	if not _is_slot_valid(slot): return
	
	origem.TimeSave = TimeGame.get_time()
	var path := Database.SAVE_PATH % slot
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(path.get_base_dir()))
	
	var err := ResourceSaver.save(origem, path)
	if err != OK:
		push_error("❌ Falha ao salvar slot %d. Código: %s" % [slot, err])
	else:
		prints_sizes(path)
		print("💾 Save salvo com sucesso no slot %d." % slot)

static func Deletar(slot: int) -> void:
	if not _is_slot_valid(slot): return
	
	var path := Database.SAVE_PATH % slot
	if FileAccess.file_exists(path):
		var err = OS.move_to_trash(ProjectSettings.globalize_path(path))
		if err == OK:
			print("🗑️ Slot %d enviado para lixeira." % slot)
		else:
			push_warning("⚠️ Falha ao excluir slot %d." % slot)

static func prints_sizes(path: String) -> void:
	var size_bytes: int = FileAccess.get_size(path)
	print("Arquivo contem: ", size_bytes)
	print("KB: ", bytes_to_kb(size_bytes))
	print("MB: ", bytes_to_mb(size_bytes))

static func bytes_to_kb(bytes: int) -> float:
	var kb: float =  bytes / 1024.0
	return round(kb * 100) / 100

static func bytes_to_mb(bytes: int) -> float:
	var mb: float = bytes / (1024.0 * 1024.0)
	return round(mb * 100) / 100

static func _is_slot_valid(slot: int) -> bool:
	if slot < 1 or slot > total_slot:
		push_error("❌ Slot inválido: %d" % slot)
		return false
	return true
