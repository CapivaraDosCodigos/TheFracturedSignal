## Classe que armazena informações extras sobre o progresso do jogo.
##
## Inclui desbloqueios, cenas já vistas e conquistas obtidas.
class_name DataExtras extends Resource

## Lista de desbloqueios do jogador (strings que representam chaves únicas).
@export var desbloqueios: Array[String] = []

## Lista de cenas já visualizadas pelo jogador.
@export var cenas_vistas: Array[String] = []

## Lista de conquistas desbloqueadas.
@export var conquistas: Array[String] = []
