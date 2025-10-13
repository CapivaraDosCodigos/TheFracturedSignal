## Classe que armazena as configurações do jogo.
##
## Inclui volume de efeitos, música, preferências de jogabilidade
## e idioma selecionado.
class_name DataConf extends Resource

## Volume dos efeitos sonoros (0-100).
@export_range(0, 100) var effects: int = 100

## Volume da música (0-100).
@export_range(0, 100) var music: int = 100

## Se verdadeiro, o jogo executa automaticamente (auto-run).
@export var auto_run: bool = false

## Idioma selecionado no jogo (por padrão "pt").
@export var idioma: String = "pt"

@export var slot_1: String = ""

@export var slot_2: String = ""

@export var slot_3: String = ""

@export var slot_4: String = ""

@export var slot_5: String = ""
