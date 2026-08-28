class_name IceProjectileNode
extends Bullet

@export var slow_duration: float = 3.0
@export var slow_magnitude: float = 0.5

func _on_area_entered(area: Area2D) -> void:
	if area is HurtboxComponent:
		area.receive_damage(damage)
		var status := area.get_parent().get_node_or_null("StatusEffectComponent") as StatusEffectComponent
		if status:
			status.apply_effect(StatusEffectComponent.EffectType.SLOW, slow_duration, slow_magnitude)
		queue_free()
