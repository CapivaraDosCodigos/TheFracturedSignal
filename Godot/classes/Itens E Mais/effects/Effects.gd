extends Resource
class_name Effect

enum EffectType {
	DANO = 1,
	BLOCKED = 2,
	SKIP = 4,
	RESISTANCE = 8,
	CURA = 16,
	FORÇA = 32
}

@export var duracao: int = 1

@export_group("Visual")
@export var Nome: String = ""
@export var icone: Texture2D
@export_multiline var descricao: String = ""

@export_group("Especificações")
@export_subgroup("Tipos")
@export_flags("DANO", "BLOCKED", "SKIP", "RESISTANCE", "CURA", "FORÇA") var tipos: int = 0

@export_subgroup("")
@export_range(0.0, 2.0, 0.05) var resistencia: float = 1.0
@export_range(0.0, 2.0, 0.05) var forca: float = 1.0
@export var cura: int = 0
@export var dano: int = 0
@export var dano_com_armadura: bool = false
@export var blocked_actions: Array[String] = []

var turnos: int = 0

func sofrer(player: PlayerData) -> void:
	if has_tipo(EffectType.BLOCKED):
		for act in blocked_actions:
			if not player.blocked_actions.has(act):
				player.blocked_actions.append(act)

	if has_tipo(EffectType.SKIP):
		player.skip_turn = true

	if has_tipo(EffectType.FORÇA):
		player.force_mult = forca

	if has_tipo(EffectType.RESISTANCE):
		player.resistance_mult = resistencia

	if has_tipo(EffectType.DANO):
		if dano_com_armadura:
			player.apply_damage(dano)
		else:
			player.Life -= dano

	if has_tipo(EffectType.CURA):
		player.Life += cura

	turnos += 1

	if turnos >= duracao:
		remover(player)

func remover(player: PlayerData) -> void:
	if has_tipo(EffectType.BLOCKED):
		for act in blocked_actions:
			while player.blocked_actions.has(act):
				player.blocked_actions.erase(act)

	if has_tipo(EffectType.SKIP):
		player.skip_turn = false

	if has_tipo(EffectType.FORÇA):
		player.force_mult = 1

	if has_tipo(EffectType.RESISTANCE):
		player.resistance_mult = 1

	turnos = 0

func has_tipo(flag: int) -> bool:
	return (tipos & flag) != 0
