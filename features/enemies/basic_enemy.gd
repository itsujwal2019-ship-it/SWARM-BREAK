class_name BasicEnemy
extends CharacterBody2D

signal died

const PROJECTILE_SCENE := preload("res://features/enemies/enemy_projectile.tscn")

@export var max_health: float = 100.0
@export var movement_speed: float = 120.0
@export var contact_damage: float = 15.0
@export var damage_interval: float = 0.5

@onready var health_component: HealthComponent = $HealthComponent
@onready var hurtbox: HurtboxComponent = $HurtboxComponent
@onready var status_effects: StatusEffectComponent = $StatusEffectComponent
@onready var body_visual: Polygon2D = $Body
@onready var _col_shape: CollisionShape2D = $CollisionShape2D

var _player: Node2D = null
var _damage_timer: float = 0.0
var _movement_multiplier: float = 1.0
var _forced_target: Node2D = null
var _forced_target_timer: float = 0.0
var _definition: EnemyDefinition = null
var _attack_timer: float = 0.0

func _ready() -> void:
	add_to_group("enemies")
	health_component.max_health = max_health
	health_component.current_health = max_health
	health_component.died.connect(_on_died)
	hurtbox.health_component = health_component

	var players := get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		_player = players[0]

func apply_definition(def: EnemyDefinition) -> void:
	_definition = def
	max_health = def.max_health
	movement_speed = def.movement_speed
	contact_damage = def.contact_damage
	damage_interval = def.damage_interval

	body_visual.color = def.body_color
	body_visual.scale = Vector2(def.body_scale, def.body_scale)

	# Scale collision capsule to match visual
	if _col_shape and _col_shape.shape is CapsuleShape2D:
		var cap := _col_shape.shape.duplicate() as CapsuleShape2D
		cap.radius = 14.0 * def.body_scale
		cap.height = 28.0 * def.body_scale
		_col_shape.shape = cap

	health_component.max_health = max_health
	health_component.current_health = max_health

func _physics_process(delta: float) -> void:
	_tick_forced_target(delta)

	if _definition != null and _definition.behavior == EnemyDefinition.Behavior.RANGED:
		_physics_ranged(delta)
	else:
		_physics_chase(delta)

func _physics_chase(delta: float) -> void:
	var target := _get_current_target()
	if target == null or not is_instance_valid(target):
		return

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

func _physics_ranged(delta: float) -> void:
	var target := _get_current_target()
	if target == null or not is_instance_valid(target):
		return

	var to_target := target.global_position - global_position
	var dist := to_target.length()
	var dir := to_target.normalized()
	var preferred := _definition.preferred_distance

	if dist < preferred * 0.75:
		velocity = -dir * movement_speed * _movement_multiplier
	elif dist > preferred * 1.25:
		velocity = dir * movement_speed * _movement_multiplier
	else:
		velocity = Vector2.ZERO
	move_and_slide()

	_attack_timer -= delta
	if _attack_timer <= 0.0 and dist <= _definition.attack_range:
		_attack_timer = _definition.attack_cooldown
		_shoot_at(target)

	# Still deal contact damage if cornered into melee range
	_damage_timer -= delta
	if _damage_timer <= 0.0:
		for i in get_slide_collision_count():
			var col := get_slide_collision(i)
			if col.get_collider() == _player:
				_player.take_damage(contact_damage)
				_damage_timer = damage_interval
				break

func _shoot_at(target: Node2D) -> void:
	var proj: EnemyProjectile = PROJECTILE_SCENE.instantiate()
	proj.direction = (target.global_position - global_position).normalized()
	proj.damage = _definition.projectile_damage
	get_tree().current_scene.add_child(proj)
	proj.global_position = global_position

func _tick_forced_target(delta: float) -> void:
	if _forced_target_timer > 0.0:
		_forced_target_timer -= delta
		if _forced_target_timer <= 0.0:
			_forced_target = null

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
