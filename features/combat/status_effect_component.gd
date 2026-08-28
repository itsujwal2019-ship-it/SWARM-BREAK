class_name StatusEffectComponent
extends Node

enum EffectType {
	FREEZE,
	SLOW,
	HEAL_OVER_TIME,
}

signal effect_applied(type: EffectType)
signal effect_removed(type: EffectType)

# { EffectType: { remaining: float, magnitude: float } }
var _active_effects: Dictionary = {}
var _owner_entity: Node

func _ready() -> void:
	_owner_entity = get_parent()

func apply_effect(type: EffectType, duration: float, magnitude: float) -> void:
	if _active_effects.has(type):
		_active_effects[type].remaining = maxf(_active_effects[type].remaining, duration)
		return
	_active_effects[type] = {"remaining": duration, "magnitude": magnitude}
	_apply_to_entity(type, magnitude)
	effect_applied.emit(type)

func _process(delta: float) -> void:
	var to_remove: Array[EffectType] = []

	for type: EffectType in _active_effects:
		_active_effects[type].remaining -= delta

		if type == EffectType.HEAL_OVER_TIME:
			if _owner_entity.has_method("heal"):
				_owner_entity.heal(_active_effects[type].magnitude * delta)

		if _active_effects[type].remaining <= 0.0:
			to_remove.append(type)

	for type in to_remove:
		_remove_effect(type)

func _apply_to_entity(type: EffectType, _magnitude: float) -> void:
	match type:
		EffectType.FREEZE, EffectType.SLOW:
			_recalculate_movement()

func _remove_effect(type: EffectType) -> void:
	_active_effects.erase(type)
	match type:
		EffectType.FREEZE, EffectType.SLOW:
			_recalculate_movement()
	effect_removed.emit(type)

func _recalculate_movement() -> void:
	var multiplier := 1.0
	if _active_effects.has(EffectType.FREEZE):
		multiplier = 0.0
	elif _active_effects.has(EffectType.SLOW):
		multiplier = 1.0 - _active_effects[EffectType.SLOW].magnitude

	if _owner_entity.has_method("set_movement_multiplier"):
		_owner_entity.set_movement_multiplier(multiplier)

func has_effect(type: EffectType) -> bool:
	return _active_effects.has(type)

func get_effect_remaining(type: EffectType) -> float:
	if _active_effects.has(type):
		return maxf(_active_effects[type].remaining, 0.0)
	return 0.0

func clear_all() -> void:
	for type: EffectType in _active_effects.keys():
		_remove_effect(type)
