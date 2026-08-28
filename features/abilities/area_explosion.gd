class_name AreaExplosionAbility
extends Ability

@export var damage: float = 80.0
@export var effect_range: float = 250.0

func _execute(owner_node: Node2D) -> void:
	for enemy in owner_node.get_tree().get_nodes_in_group("enemies"):
		if not enemy is Node2D:
			continue
		if owner_node.global_position.distance_to(enemy.global_position) <= effect_range:
			if enemy.has_method("take_damage"):
				enemy.take_damage(damage)
	_show_explosion(owner_node)

func _show_explosion(owner_node: Node2D) -> void:
	var circle := Polygon2D.new()
	circle.polygon = _circle_polygon(effect_range, 24)
	circle.color = Color(1.0, 0.4, 0.1, 0.5)
	circle.global_position = owner_node.global_position
	owner_node.get_tree().current_scene.add_child(circle)
	owner_node.get_tree().create_timer(0.2).timeout.connect(circle.queue_free)

func _circle_polygon(radius: float, points: int) -> PackedVector2Array:
	var verts := PackedVector2Array()
	for i in points:
		var a := (float(i) / points) * TAU
		verts.append(Vector2(cos(a), sin(a)) * radius)
	return verts
