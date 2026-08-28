class_name AreaHealAbility
extends Ability

@export var heal_amount: float = 30.0
@export var effect_range: float = 300.0

func _execute(owner_node: Node2D) -> void:
	for ally in owner_node.get_tree().get_nodes_in_group("allies"):
		if not ally is Node2D:
			continue
		if owner_node.global_position.distance_to(ally.global_position) <= effect_range:
			if ally.has_method("heal"):
				ally.heal(heal_amount)
	_show_effect_range_flash(owner_node)

func _show_effect_range_flash(owner_node: Node2D) -> void:
	var circle := Polygon2D.new()
	circle.polygon = _circle_polygon(effect_range, 24)
	circle.color = Color(0.3, 1.0, 0.5, 0.25)
	circle.global_position = owner_node.global_position
	owner_node.get_tree().current_scene.add_child(circle)
	owner_node.get_tree().create_timer(0.25).timeout.connect(circle.queue_free)

func _circle_polygon(radius: float, points: int) -> PackedVector2Array:
	var verts := PackedVector2Array()
	for i in points:
		var a := (float(i) / points) * TAU
		verts.append(Vector2(cos(a), sin(a)) * radius)
	return verts
