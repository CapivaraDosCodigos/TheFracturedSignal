@tool
extends Node

@onready var fps_label: Label = %fps_label
@onready var Menu: CanvasLayer = $MENU
@onready var cfg: PostProcessingConfiguration = $PostProcess.configuration
@onready var audio := $AudioPlayerZ; @onready var audio2 := $AudioPlayerS

enum GameState { MAP, BATTLE, CUTSCENES, DIALOGUE, BATTLE_MENU, NOT_IN_THE_GAME}
const GameStateString: Array[String] = ["MAP", "BATTLE", "CUTSCENES", "DIALOGUE", "BATTLE_MENU", "NOT_IN_THE_GAME"]
const batalha2d: PackedScene = preload("res://Areais/Batalha/cenas/BATALHA.tscn")

@export var current_status: GameState = GameState.MAP: set = change_state
var raio: RayCast2D; var Body: Node; var ObjectPlayer: ObjectPlayer2D
var textureD: Texture; var materialD: ShaderMaterial
var naoesperardialogo: bool = true

#signal SignalDialogue(dict: Dictionary)

#func _ready():
	#var path = "res://escopo.txt"
	#if FileAccess.file_exists(path):
		#var file = FileAccess.open(path, FileAccess.READ)
		#var conteudo = file.get_as_text()
		#file.close()
		#print(conteudo)

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	var camada: int
	if ObjectPlayer != null:
		camada = ObjectPlayer.camada
		
	fps_label.text = "FPS: " + str(Engine.get_frames_per_second()) + ", CurrentStatus: " + GameStateString[current_status] + ", camada: " + str(camada)
	
	if raio != null or not naoesperardialogo:
		if Input.is_action_just_pressed("confirm"):
			if raio.is_colliding():
				Body = raio.get_collider()
		else:
			Body = null
	else:
		Body = null

func esperardialogo() -> void:
	await get_tree().create_timer(0.5).timeout
	change_state(Manager.GameState.MAP)
	#naoesperardialogo = true

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

func tocar_musica_manager(caminho: String = "", volume: float = 100.0, loop: bool = true, atraso: float = 0.0, canal: int = 1) -> void:
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

func StartBatalha(batalha: DataBatalha, pos: Vector2 = Vector2.ZERO) -> void:
	var batalhaInstantiante := batalha2d.instantiate()
	Manager.tocar_musica_manager("res://sons/sounds/Deltarune - Sound Effect Battle Start Jingle(MP3_160K).mp3", 100, false, 0.0, 2)
	batalha.dungeons2D.iniciar_batalha()
	batalhaInstantiante.batalha = batalha
	batalhaInstantiante.global_position = pos
	add_sibling(batalhaInstantiante)

func DialogoTexture(texture: String = "", material: String = "") -> void:
	if texture == "":
		textureD = null
	else:
		textureD = load(texture)
	
	if material == "":
		materialD = null
	else:
		materialD = load(material)

#func _ready() -> void:
	#var _shader_material := preload("res://texture/folderTres/materials/tile.tres")
	#var _path := "res://texture/objetos/16x16.png"
	#var _path2 := "res://texture/PNG/funds/Border All 3.png"
	#print(Starts.ZenoData.armorE)
	#Database.equip_armor(Starts.InvData, Starts.ZenoData, 2)
	#print(Starts.ZenoData.armorE)
	#salvar_print_visivel()
	#$time.aplicar_material_e_salvar(_path, _shader_material)
	#$time.aplicar_material_e_salvar(_path2, _shader_material)
