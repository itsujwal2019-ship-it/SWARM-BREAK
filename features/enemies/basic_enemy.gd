class_name BasicEnemy
extends CharacterBody2D

signal died

@export var max_health: float = 30.0
@export var movement_speed: float = 100.0
@export var contact_damage: float = 10.0
@export var damage_interval: float = 0.5

@onready var health_component: HealthComponent = $HealthComponent
@onready var hurtbox: HurtboxComponent = $HurtboxComponent
@onready var status_effects: StatusEffectComponent = $StatusEffectComponent
@onready var body_visual: Polygon2D = $Body

var _player: CharacterBody2D = null
var _damage_timer: float = 0.0
var _movement_multiplier: float = 1.0
var _forced_target: Node2D = null
var _forced_target_timer: float = 0.0

func _ready() -> void:
	add_to_group("enemies")
	health_component.max_health = max_health
	health_component.current_health = max_health
	health_component.died.connect(_on_died)
	hurtbox.health_component = health_component

	var players := get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		_player = players[0]

func _physics_process(delta: float) -> void:
	var target := _get_current_target()
	if target == null or not is_instance_valid(target):
		return

	if _forced_target_timer > 0.0:
		_forced_target_timer -= delta
		if _forced_target_timer <= 0.0:
			_forced_target = null

	var dir := (target.global_position - global_position).normalized()
	velocity = dir * movement_speed * _movement_multiplier
	move_and_slide()

	_damage_timer -= delta
	if _damage_timer <= 0.0:
		for i in get_slide_collision_count():
			var col := get_slide_collision(i)
			if col.get_collider() == _player:
				_player.take_damage(contact_damage)
				_damage_timer = damage_interval
				break

func _get_current_target() -> Node2D:
	if _forced_target != null and is_instance_valid(_forced_target):
		return _forced_target
	return _player

func set_forced_target(target: Node2D, duration: float) -> void:
	_forced_target = target
	_forced_target_timer = duration

func set_movement_multiplier(value: float) -> void:
	_movement_multiplier = value
	_update_freeze_visual()

func take_damage(amount: float) -> void:
	health_component.take_damage(amount)

func _update_freeze_visual() -> void:
	if body_visual == null:
		return
	if _movement_multiplier <= 0.0:
		body_visual.modulate = Color(0.5, 0.85, 1.0, 1.0)
	elif _movement_multiplier < 1.0:
		body_visual.modulate = Color(0.7, 0.85, 1.0, 1.0)
	else:
		body_visual.modulate = Color(1.0, 1.0, 1.0, 1.0)

func _on_died() -> void:
	died.emit()
	queue_free()
