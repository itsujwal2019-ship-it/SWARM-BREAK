class_name Ability
extends Resource

@export var ability_name: String = ""
@export var cooldown: float = 1.0

var _current_cooldown: float = 0.0

func can_activate() -> bool:
	return _current_cooldown <= 0.0

func activate(owner_node: Node2D) -> void:
	if not can_activate():
		return
	_current_cooldown = cooldown
	_execute(owner_node)

func _execute(_owner_node: Node2D) -> void:
	pass

func tick(delta: float) -> void:
	if _current_cooldown > 0.0:
		_current_cooldown -= delta

func get_remaining_cooldown() -> float:
	return maxf(_current_cooldown, 0.0)

func get_cooldown_ratio() -> float:
	if cooldown <= 0.0:
		return 1.0
	return clampf(1.0 - (_current_cooldown / cooldown), 0.0, 1.0)
