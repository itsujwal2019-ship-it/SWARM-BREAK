class_name Weapon
extends Node2D

@export var damage: float = 10.0
@export var fire_rate: float = 10.0
@export var bullet_speed: float = 800.0
@export var bullet_lifetime: float = 2.0
@export var bullet_scene: PackedScene

var _fire_timer: float = 0.0
var _projectile_container: Node2D
var _muzzle: Node2D

func _ready() -> void:
	_muzzle = get_node_or_null("Muzzle")
	_projectile_container = get_tree().get_first_node_in_group("projectiles")

func _process(delta: float) -> void:
	if _fire_timer > 0.0:
		_fire_timer -= delta

func can_shoot() -> bool:
	return _fire_timer <= 0.0

func shoot(direction: Vector2) -> void:
	if not can_shoot() or bullet_scene == null:
		return
	_fire_timer = 1.0 / fire_rate

	var bullet: Bullet = bullet_scene.instantiate()
	bullet.direction = direction
	bullet.speed = bullet_speed
	bullet.damage = damage
	bullet.lifetime = bullet_lifetime
	var spawn_pos := _muzzle.global_position if _muzzle else global_position
	bullet.global_position = spawn_pos

	var container := _projectile_container if _projectile_container else get_tree().current_scene
	container.add_child(bullet)
