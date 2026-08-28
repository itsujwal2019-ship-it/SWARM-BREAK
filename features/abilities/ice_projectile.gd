class_name IceProjectileAbility
extends Ability

const ICE_SCENE := preload("res://features/abilities/ice_projectile.tscn")

@export var damage: float = 25.0
@export var speed: float = 650.0
@export var lifetime: float = 2.5
@export var slow_duration: float = 3.0

func _execute(owner_node: Node2D) -> void:
	var container := owner_node.get_tree().get_first_node_in_group("projectiles")
	if container == null:
		container = owner_node.get_tree().current_scene

	var projectile: IceProjectileNode = ICE_SCENE.instantiate()
	projectile.direction = (owner_node.get_global_mouse_position() - owner_node.global_position).normalized()
	projectile.speed = speed
	projectile.damage = damage
	projectile.lifetime = lifetime
	projectile.slow_duration = slow_duration
	projectile.global_position = owner_node.global_position
	container.add_child(projectile)
