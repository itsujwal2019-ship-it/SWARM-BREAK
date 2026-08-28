class_name Game
extends Node2D

enum State { PLAYING, GAME_OVER }

const CHARACTER_DEFS := [
	"res://features/characters/fire_wizard.tres",
	"res://features/characters/ice_wizard.tres",
	"res://features/characters/healer.tres",
	"res://features/characters/tank.tres",
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

const DIFFICULTY_STAGES := [
	{"time": 0.0,  "interval": 1.5},
	{"time": 30.0, "interval": 1.2},
	{"time": 60.0, "interval": 1.0},
	{"time": 90.0, "interval": 0.8},
]

func _ready() -> void:
	player.player_died.connect(_on_player_died)
	spawner.enemy_spawned.connect(_on_enemy_spawned)
	game_over_layer.hide()
	# Default to Fire Wizard
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

func register_kill() -> void:
	_kills += 1
	hud.update_kills(_kills)

func _update_difficulty() -> void:
	var interval: float = DIFFICULTY_STAGES[0].interval
	for stage in DIFFICULTY_STAGES:
		if _elapsed_time >= stage.time:
			interval = stage.interval
	spawner.update_interval(interval)

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
