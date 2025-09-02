extends Node

@onready var audio := $AudioPlayerZ; @onready var audio2 := $AudioPlayerS

enum GameState { MAP, BATTLE, CUTSCENES, DIALOGUE, BATTLE_MENU, NOT_IN_THE_GAME}

var inimigosA: Array[EnemiesBase] = []
var current_status: GameState = GameState.MAP: set = change_state
var raio: RayCast2D; var BodyInteract: Node; var Body: Node
var InteractionMode: String = "balloonZ"
var cfg: PostProcessingConfiguration

func _ready() -> void:
	cfg = $PostProcess.configuration as PostProcessingConfiguration

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("confirm") and raio != null:
		if raio.is_colliding():
			Body = raio.get_collider()
	else:
		Body = null
	
	if raio != null and raio.is_colliding():
		BodyInteract = raio.get_collider()
	else:
		BodyInteract = null
		if InteractionMode != "":
			InteractionMode = ""
	
	if current_status != GameState.MAP:
		if InteractionMode != "":
			InteractionMode = ""

func _input(_event: InputEvent) -> void:
	pass
	#var _shader_material := preload("res://textures/folder tres/materials/tile3.tres")
	#var _imagem_path := "res://texture/characters/Zeno's/Niko.png"
	#if Input.is_action_just_pressed("menu"):
		#Starts.SAVE(1)
		#print(Starts.ZenoData.armorE)
		#Database.equip_armor(Starts.InvData, Starts.ZenoData, 2)
		#print(Starts.ZenoData.armorE)
		#salvar_print_visivel()
		#$time.aplicar_material_e_salvar(_imagem_path, _shader_material)

func change_state(estado: GameState) -> void:
	current_status = estado

func nova_palette(caminho: String, ligado: bool = true) -> void:
	cfg.Palette = ligado
	if not ligado:
		return
	
	if not ResourceLoader.exists(caminho):
		push_warning("⚠️ Caminho inválido: " + caminho)
		return
	
	var textureload = load(caminho)
	if textureload == null or not textureload is Texture2D:
		push_warning("⚠️ Arquivo não é um texture2D válido: " + caminho)
		return
	
	cfg.PalettePalette = textureload

func tocar_musica_manager(caminho: String, volume: float = 100.0, loop: bool = true, atraso: float = 0.0, canal: int = 1) -> void:
	if canal == 1:
		audio.tocar_musica(caminho, volume, loop, atraso)
	elif canal == 2:
		audio2.tocar_musica(caminho, volume, loop, atraso)
	else:
		push_warning("⚠️ Não existe canal" + str(canal))
		return

func SceneTransition(caminho: String) -> void:
	if not ResourceLoader.exists(caminho):
		push_error("❌ Caminho da cena inválido: " + caminho)
		return
		
	$%fundo.visible = false
	get_tree().change_scene_to_file(caminho)
	await get_tree().create_timer(0.1).timeout
	$%fundo.visible = true

func StartBatalha(inimigos: Array[EnemiesBase]) -> void:
	inimigosA = inimigos
	SceneTransition("res://Godot/Batalha/cenas/BATALHA.tscn")

#func _salvar_print_visivel():
	#var img = get_viewport().get_texture().get_image()
	#var dir = OS.get_system_dir(OS.SYSTEM_DIR_PICTURES)
	#var nome = "screenshot_" + Time.get_time_string_from_system().replace(":", "-") + ".png"
	#var caminho = dir + "/" + nome
	#img.save_png(caminho)
	#print("Salvo em:", caminho)
