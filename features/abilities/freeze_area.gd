class_name FreezeAreaAbility
extends Ability

@export var effect_range: float = 300.0
@export var freeze_duration: float = 3.0

func _execute(owner_node: Node2D) -> void:
	for enemy in owner_node.get_tree().get_nodes_in_group("enemies"):
		if not enemy is Node2D:
			continue
		if owner_node.global_position.distance_to(enemy.global_position) <= effect_range:
			var status := enemy.get_node_or_null("StatusEffectComponent") as StatusEffectComponent
			if status:
				status.apply_effect(StatusEffectComponent.EffectType.FREEZE, freeze_duration, 1.0)
	_show_effect_range_flash(owner_node)

func _show_effect_range_flash(owner_node: Node2D) -> void:
	var circle := Polygon2D.new()
	circle.polygon = _circle_polygon(effect_range, 24)
	circle.color = Color(0.4, 0.8, 1.0, 0.35)
	circle.global_position = owner_node.global_position
	owner_node.get_tree().current_scene.add_child(circle)
	owner_node.get_tree().create_timer(0.3).timeout.connect(circle.queue_free)

func _circle_polygon(radius: float, points: int) -> PackedVector2Array:
	var verts := PackedVector2Array()
	for i in points:
		var a := (float(i) / points) * TAU
		verts.append(Vector2(cos(a), sin(a)) * radius)
	return verts
