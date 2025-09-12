extends Node

@onready var fps_label: Label = %fps_label
@onready var Menu: CanvasLayer = $MENU
@onready var cfg: PostProcessingConfiguration = $PostProcess.configuration
@onready var audio := $AudioPlayerZ; @onready var audio2 := $AudioPlayerS

enum GameState { MAP, BATTLE, CUTSCENES, DIALOGUE, BATTLE_MENU, NOT_IN_THE_GAME}

var inimigosA: Array[EnemiesBase] = []; var batalha: DataBatalha = DataBatalha.new()
var current_status: GameState = GameState.MAP: set = change_state
var raio: RayCast2D; var Body: Node; var textureD: Texture; var materialD: ShaderMaterial
var batalha2d := preload("res://Godot/Batalha/cenas/BATALHA.tscn")

func _physics_process(_delta: float) -> void:
	fps_label.text = "FPS: %d" % Engine.get_frames_per_second()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("confirm") and raio != null:
		if raio.is_colliding():
			Body = raio.get_collider()
	else:
		Body = null

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

func StartBatalha(batalhaS: DataBatalha) -> void:
	batalha = batalhaS
	inimigosA = batalha.inimigosB
	#
	#var bat := batalha2d.instantiate()
	#get_tree().call_deferred("add_child", bat)

func DialogoTexture(texture: String = "", material: String = "") -> void:
	if texture == "":
		textureD = null
	else:
		textureD = load(texture)
	
	if material == "":
		materialD = null
	else:
		materialD = load(material)

#func _salvar_print_visivel():
	#var img = get_viewport().get_texture().get_image()
	#var dir = OS.get_system_dir(OS.SYSTEM_DIR_PICTURES)
	#var nome = "screenshot_" + Time.get_time_string_from_system().replace(":", "-") + ".png"
	#var caminho = dir + "/" + nome
	#img.save_png(caminho)
	#print("Salvo em:", caminho)
#func _ready() -> void:
	#var _shader_material := preload("res://texture/folder tres/materials/tile3.tres")
	#var _path := "res://texture/PNG/funds/Border All 6.png"
	#var _path2 := "res://texture/PNG/funds/Border All 3.png"
	#print(Starts.ZenoData.armorE)
	#Database.equip_armor(Starts.InvData, Starts.ZenoData, 2)
	#print(Starts.ZenoData.armorE)
	#salvar_print_visivel()
	#$time.aplicar_material_e_salvar(_path, _shader_material)
	#$time.aplicar_material_e_salvar(_path2, _shader_material)
