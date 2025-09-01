class_name SaveData extends Resource

enum TIPO_DATAS { Global, NotSave }

static var not_save_path: String = Database.PATH_NOT_SAVE
static var save_path: String = Database.SAVE_PATH
static var total_slot: int = Database.TOTAL_SLOTS

static func Carregar(slot: int, tipo: TIPO_DATAS) -> Datas:
	if not _is_slot_valid(slot):
		push_warning("erro slot invalido")
		return null
	
	match tipo:
		TIPO_DATAS.Global:
			var path := save_path % slot
			if not ResourceLoader.exists(path):
				print("📂 Nenhum save no slot %d." % slot)
				return GlobalData.new()
			
			var loaded_data = ResourceLoader.load(path)
			print("✅ Dados carregados do slot %d." % slot)
			return loaded_data
			
		TIPO_DATAS.NotSave:
			var path := not_save_path % slot
			if not ResourceLoader.exists(path):
				print("📂 Nenhum save no slot %d." % slot)
				return GlobalData.new()
			
			var loaded_data = ResourceLoader.load(path)
			print("✅ Dados carregados do slot %d." % slot)
			return loaded_data
	
	push_warning("erro, sem tipo")
	return null

static func Carregar_Arquivo(caminho: String) -> Datas:
	if not ResourceLoader.exists(caminho):
		push_warning("📂 Arquivo não encontrado: " + caminho)
		return null
	
	var loaded_data = ResourceLoader.load(caminho)
	print("✅ Dados carregados de:", caminho)
	return loaded_data

static func Salvar(slot: int, origem: Datas, tipo: TIPO_DATAS) -> void:
	if not _is_slot_valid(slot): return
	
	match tipo:
		TIPO_DATAS.Global:
			var path := save_path % slot
			var err := ResourceSaver.save(origem, path)
			if err != OK:
				push_error("❌ Falha ao salvar slot %d. Código de erro: %s" % [slot, err])
			else:
				print("💾 Dados salvos no slot %d." % slot)
		TIPO_DATAS.NotSave:
			var path := not_save_path % slot
			var err := ResourceSaver.save(origem, path)
			if err != OK:
				push_error("❌ Falha ao salvar slot %d. Código de erro: %s" % [slot, err])
			else:
				print("💾 Dados salvos no slot %d." % slot)

static func Deletar(slot: int, tipo: TIPO_DATAS) -> void:
	if not _is_slot_valid(slot): return
	match tipo:
		TIPO_DATAS.Global:
			var path := save_path % slot
			if FileAccess.file_exists(path):
				OS.move_to_trash(ProjectSettings.globalize_path(path))
				print("🗑️ Slot %d apagado." % slot)
			else:
				print("📭 Slot %d já estava vazio." % slot)
			
		TIPO_DATAS.NotSave:
			var path := not_save_path % slot
			if FileAccess.file_exists(path):
				OS.move_to_trash(ProjectSettings.globalize_path(path))
				print("🗑️ Slot %d apagado." % slot)
			else:
				print("📭 Slot %d já estava vazio." % slot)

static func _is_slot_valid(slot: int) -> bool:
	if slot < 1 or slot > total_slot:
		push_error("❌ Slot inválido: %d" % slot)
		return false
	return true
