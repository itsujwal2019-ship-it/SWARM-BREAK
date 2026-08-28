class_name HealOverTimeAbility
extends Ability

@export var heal_per_second: float = 5.0
@export var duration: float = 5.0
@export var effect_range: float = 300.0

func _execute(owner_node: Node2D) -> void:
	for ally in owner_node.get_tree().get_nodes_in_group("allies"):
		if not ally is Node2D:
			continue
		if owner_node.global_position.distance_to(ally.global_position) > effect_range:
			continue
		var status := ally.get_node_or_null("StatusEffectComponent") as StatusEffectComponent
		if status:
			status.apply_effect(StatusEffectComponent.EffectType.HEAL_OVER_TIME, duration, heal_per_second)
