class_name ShieldAbility
extends Ability

@export var shield_amount: float = 100.0
@export var duration: float = 5.0

func _execute(owner_node: Node2D) -> void:
	var health := owner_node.get_node_or_null("HealthComponent") as HealthComponent
	if health:
		health.add_shield(shield_amount, duration)
