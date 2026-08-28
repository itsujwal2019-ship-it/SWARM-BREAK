class_name BasicEnemy
extends CharacterBody2D

signal died

@export var max_health: float = 30.0
@export var movement_speed: float = 100.0
@export var contact_damage: float = 10.0
@export var damage_interval: float = 0.5

@onready var health_component: HealthComponent = $HealthComponent
@onready var hurtbox: HurtboxComponent = $HurtboxComponent

var _player: CharacterBody2D = null
var _damage_timer: float = 0.0

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
	if _player == null or not is_instance_valid(_player):
		return

	var dir := (_player.global_position - global_position).normalized()
	velocity = dir * movement_speed
	move_and_slide()

	_damage_timer -= delta
	if _damage_timer <= 0.0:
		for i in get_slide_collision_count():
			var col := get_slide_collision(i)
			if col.get_collider() == _player:
				_player.take_damage(contact_damage)
				_damage_timer = damage_interval
				break

func _on_died() -> void:
	died.emit()
	queue_free()
