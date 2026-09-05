class_name Game
extends Node2D

enum State { PLAYING, GAME_OVER }

const CHARACTER_DEFS := [
	"res://features/characters/fire_wizard.tres",
	"res://features/characters/ice_wizard.tres",
	"res://features/characters/healer.tres",
	"res://features/characters/tank.tres",
]

const ENEMY_DEF_PATHS := {
	"chaser":       "res://features/enemies/data/chaser.tres",
	"runner":       "res://features/enemies/data/runner.tres",
	"brute":        "res://features/enemies/data/brute.tres",
	"ranged_enemy": "res://features/enemies/data/ranged_enemy.tres",
}

# Each stage: spawn interval + which enemy IDs are in the pool (duplicates = higher weight)
const DIFFICULTY_STAGES := [
	{"time":  0.0, "interval": 1.5, "pool": ["chaser", "chaser", "chaser"]},
	{"time":  8.0, "interval": 1.2, "pool": ["chaser", "chaser", "runner"]},
	{"time": 14.0, "interval": 1.0, "pool": ["chaser", "runner", "brute"]},
	{"time": 2.0, "interval": 0.8, "pool": ["chaser", "runner", "brute", "ranged_enemy"]},
]

@onready var player: Player = $Player
@onready var spawner: EnemySpawner = $EnemySpawner
@onready var hud: HUD = $HUD
@onready var game_over_layer: CanvasLayer = $GameOverLayer
@onready var survival_label: Label = $GameOverLayer/GameOverScreen/VBox/SurvivalLabel
@onready var kills_label_go: Label = $GameOverLayer/GameOverScreen/VBox/KillsLabel

var _state: State = State.PLAYING
var _elapsed_time: float = 0.0
var _kills: int = 0
var _current_char_index: int = 0
var _current_stage: int = -1
var _enemy_defs: Dictionary = {}

func _ready() -> void:
	for id in ENEMY_DEF_PATHS:
		_enemy_defs[id] = load(ENEMY_DEF_PATHS[id])

	player.player_died.connect(_on_player_died)
	spawner.enemy_spawned.connect(_on_enemy_spawned)
	game_over_layer.hide()
	_select_character(0)

func _on_enemy_spawned(enemy: BasicEnemy) -> void:
	enemy.died.connect(register_kill)

func _process(delta: float) -> void:
	if _state != State.PLAYING:
		return
	_elapsed_time += delta
	_update_difficulty()
	_update_hud()

func _unhandled_key_input(event: InputEvent) -> void:
	if _state != State.PLAYING:
		return
	if event.is_action_pressed("select_char_next"):
		_current_char_index = (_current_char_index + 1) % CHARACTER_DEFS.size()
		_select_character(_current_char_index)

func _select_character(index: int) -> void:
	var def: CharacterDefinition = load(CHARACTER_DEFS[index])
	if def:
		player.apply_character(def)
		hud.update_character(def.display_name + "  [Tab]")

func _update_hud() -> void:
	var hc := player.health_component
	hud.update_health(hc.current_health, hc.max_health)
	hud.update_shield(hc.shield)
	hud.update_time(_elapsed_time)

	var ac := player.ability_controller
	hud.update_abilities(ac.get_ability_1(), ac.get_ability_2())

	var hot := 0.0
	var status := player.get_node_or_null("StatusEffectComponent") as StatusEffectComponent
	if status:
		hot = status.get_effect_remaining(StatusEffectComponent.EffectType.HEAL_OVER_TIME)
	hud.update_active_effects(hot)

func _update_difficulty() -> void:
	var best := 0
	for i in DIFFICULTY_STAGES.size():
		if _elapsed_time >= DIFFICULTY_STAGES[i].time:
			best = i

	spawner.update_interval(DIFFICULTY_STAGES[best].interval)

	if best != _current_stage:
		_current_stage = best
		_apply_stage_pool(best)

func _apply_stage_pool(idx: int) -> void:
	var ids: Array = DIFFICULTY_STAGES[idx].pool
	var defs: Array = []
	for id in ids:
		if _enemy_defs.has(id) and _enemy_defs[id] != null:
			defs.append(_enemy_defs[id])
	spawner.set_pool(defs)

func register_kill() -> void:
	_kills += 1
	hud.update_kills(_kills)

func _on_player_died() -> void:
	_state = State.GAME_OVER
	spawner.deactivate()
	survival_label.text = "SURVIVED: " + _format_time(_elapsed_time)
	kills_label_go.text = "KILLS: " + str(_kills)
	game_over_layer.show()

func _format_time(seconds: float) -> String:
	var m := int(seconds / 60.0)
	var s := int(seconds) - m * 60
	return "%02d:%02d" % [m, s]

func _on_restart_pressed() -> void:
	get_tree().reload_current_scene()
