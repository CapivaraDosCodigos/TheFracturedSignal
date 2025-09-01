## Classe que armazena dados globais do jogo.
##
## Usada como container para manter informações persistentes
## durante toda a execução, como dados do jogador, configurações
## e dados extras (desbloqueios, conquistas etc).
@icon("res://texture/folder tres/save_png.tres")
class_name GlobalData extends Datas

## nome que vai aparecer nos saves
@export var name: String = ""

## inventario global.
@export var Inv: InventoryData = preload("res://Godot/classes/itens/começo.tres")

## lista com os dados dos personagens.
@export var CharDir: Dictionary[String, PlayerData] = {"Zeno": preload("res://Godot/classes/personagens/zeno.tres")}

## personagem principal selecionado.
@export var current_player: PlayerData = PlayerData.new()

## Configurações do jogo.
@export var Conf: DataConf = DataConf.new()

## Dados extras do jogo (desbloqueios, conquistas, etc.).
@export var DataE: DataExtras = DataExtras.new()
