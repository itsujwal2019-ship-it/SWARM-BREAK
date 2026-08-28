class_name EnemySpawner
extends Node2D

signal enemy_spawned(enemy: BasicEnemy)

@export var enemy_scene: PackedScene
@export var min_spawn_distance: float = 200.0
@export var spawn_radius: float = 600.0

var _spawn_timer: float = 0.0
var _current_interval: float = 1.5
var _enemy_container: Node2D
var _player: Node2D
var _active: bool = true

func _ready() -> void:
	_enemy_container = get_tree().get_first_node_in_group("enemies_container")

func activate() -> void:
	_active = true

func deactivate() -> void:
	_active = false

func update_interval(interval: float) -> void:
	_current_interval = interval

func _process(delta: float) -> void:
	if not _active:
		return

	if _player == null or not is_instance_valid(_player):
		var players := get_tree().get_nodes_in_group("player")
		if players.is_empty():
			return
		_player = players[0]

	_spawn_timer -= delta
	if _spawn_timer <= 0.0:
		_spawn_timer = _current_interval
		_spawn_enemy()

func _spawn_enemy() -> void:
	if enemy_scene == null or _player == null:
		return

	var spawn_pos := _get_spawn_position()
	var enemy: BasicEnemy = enemy_scene.instantiate()
	enemy.global_position = spawn_pos

	var container := _enemy_container if _enemy_container else get_tree().current_scene
	container.add_child(enemy)
	enemy_spawned.emit(enemy)

func _get_spawn_position() -> Vector2:
	var angle := randf() * TAU
	var dist := randf_range(min_spawn_distance, spawn_radius)
	return _player.global_position + Vector2(cos(angle), sin(angle)) * dist
