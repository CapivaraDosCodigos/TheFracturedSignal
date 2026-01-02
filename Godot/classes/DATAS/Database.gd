#ItemDatabase.gd
class_name Database extends Resource

const TOTAL_SLOTS := 5
const SAVE_PATH := "user://season_resource_slot_%d.tres"
const PLAYERS_DISPONIVEIS_STRING: Array[String] = ["Zeno", "Niko"]

enum PLAYERS_DISPONIVEIS {Zeno, Niko}

#Armas:
const SIGNAL_WEAPON: ItemArma = preload("res://Godot/classes/Itens E Mais/armas/Signal_Weapon.tres")
const WEAPONNULL: ItemArma = preload("res://Godot/classes/Itens E Mais/armas/sem_arma.tres")

#Armaduras:
const OCULOS_SIMPLES: ItemArmadura = preload("res://Godot/classes/Itens E Mais/armaduras/óculos_simples.tres")
const ARMORNULL: ItemArmadura = preload("res://Godot/classes/Itens E Mais/armaduras/sem_armadura.tres")

#Consumíveis
const SANDWICH: ItemConsumivel = preload("res://Godot/classes/Itens E Mais/consumíveis/sandwich.tres")
