class_name FireballAbility
extends Ability

const FIREBALL_SCENE := preload("res://features/abilities/fireball_projectile.tscn")

@export var damage: float = 50.0
@export var speed: float = 600.0
@export var lifetime: float = 3.0

func _execute(owner_node: Node2D) -> void:
	var container := owner_node.get_tree().get_first_node_in_group("projectiles")
	if container == null:
		container = owner_node.get_tree().current_scene

	var projectile: Bullet = FIREBALL_SCENE.instantiate()
	projectile.direction = (owner_node.get_global_mouse_position() - owner_node.global_position).normalized()
	projectile.speed = speed
	projectile.damage = damage
	projectile.lifetime = lifetime
	projectile.global_position = owner_node.global_position
	container.add_child(projectile)
