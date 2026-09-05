class_name EnemySpawner
extends Node2D

signal enemy_spawned(enemy: BasicEnemy)

const ENEMY_SCENE   := preload("res://features/enemies/basic_enemy.tscn")
const WARNING_SCENE := preload("res://features/enemies/spawn_warning.tscn")

@export var min_spawn_distance: float = 220.0
@export var spawn_radius: float = 620.0

var _spawn_timer: float = 0.0
var _current_interval: float = 1.5
var _enemy_container: Node2D = null
var _player: Node2D = null
var _active: bool = true
var _definition_pool: Array = []

func _ready() -> void:
	_enemy_container = get_tree().get_first_node_in_group("enemies_container")

func activate() -> void:
	_active = true

func deactivate() -> void:
	_active = false

func update_interval(interval: float) -> void:
	_current_interval = interval

func set_pool(defs: Array) -> void:
	_definition_pool = defs

func _process(delta: float) -> void:
	if not _active or _definition_pool.is_empty():
		return

	if _player == null or not is_instance_valid(_player):
		var players := get_tree().get_nodes_in_group("player")
		if players.is_empty():
			return
		_player = players[0]

	_spawn_timer -= delta
	if _spawn_timer <= 0.0:
		_spawn_timer = _current_interval
		var def: EnemyDefinition = _definition_pool[randi() % _definition_pool.size()]
		_spawn_with_warning(def)

func _spawn_with_warning(def: EnemyDefinition) -> void:
	var pos := _get_spawn_position()
	var container := _get_container()

	var warning: Node2D = WARNING_SCENE.instantiate()
	warning.global_position = pos
	warning.duration = def.spawn_warning_duration
	container.add_child(warning)

	await get_tree().create_timer(def.spawn_warning_duration).timeout

	if not is_instance_valid(self) or not _active:
		return

	var enemy: BasicEnemy = ENEMY_SCENE.instantiate()
	enemy.global_position = pos
	container.add_child(enemy)
	enemy.apply_definition(def)
	enemy_spawned.emit(enemy)

func _get_spawn_position() -> Vector2:
	if _player == null:
		return Vector2.ZERO
	var angle := randf() * TAU
	var dist := randf_range(min_spawn_distance, spawn_radius)
	return _player.global_position + Vector2(cos(angle), sin(angle)) * dist

func _get_container() -> Node:
	if _enemy_container != null and is_instance_valid(_enemy_container):
		return _enemy_container
	return get_tree().current_scene
