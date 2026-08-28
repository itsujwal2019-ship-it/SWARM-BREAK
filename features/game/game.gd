class_name Game
extends Node2D

enum State { PLAYING, GAME_OVER }

@onready var player: Player = $Player
@onready var spawner: EnemySpawner = $EnemySpawner
@onready var hud: HUD = $HUD
@onready var game_over_layer: CanvasLayer = $GameOverLayer
@onready var survival_label: Label = $GameOverLayer/GameOverScreen/VBox/SurvivalLabel
@onready var kills_label_go: Label = $GameOverLayer/GameOverScreen/VBox/KillsLabel

var _state: State = State.PLAYING
var _elapsed_time: float = 0.0
var _kills: int = 0

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

func _on_enemy_spawned(enemy: BasicEnemy) -> void:
	enemy.died.connect(register_kill)

func _process(delta: float) -> void:
	if _state != State.PLAYING:
		return

	_elapsed_time += delta
	_update_difficulty()
	hud.update_time(_elapsed_time)
	hud.update_health(player.get_health_ratio())

func register_kill() -> void:
	_kills += 1
	hud.update_kills(_kills)

func _update_difficulty() -> void:
	var interval := DIFFICULTY_STAGES[0].interval
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
