## Classe que armazena as configurações do jogo.
##
## Inclui volume de efeitos, música, preferências de jogabilidade
## e idioma selecionado.
class_name DataConf extends Resource

## Volume dos efeitos sonoros (0-100).
@export_range(0, 100) var sound_effects: float = 100.0

## Volume da música (0-100).
@export_range(0, 100) var music: float = 100.0

## Se verdadeiro, o jogo executa automaticamente (auto-run).
@export var auto_run: bool = false

## Se verdadeiro, mostra o fps na tela.
@export var fps_bool: bool = false

## Idioma selecionado no jogo (por padrão "pt").
@export var idioma: String = "pt"
