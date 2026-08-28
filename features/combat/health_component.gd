class_name HealthComponent
extends Node

signal health_changed(current: float, max: float)
signal shield_changed(amount: float)
signal died

@export var max_health: float = 100.0

var current_health: float
var shield: float = 0.0

func _ready() -> void:
	current_health = max_health

func take_damage(amount: float) -> void:
	if current_health <= 0.0:
		return
	var remaining := amount
	if shield > 0.0:
		var absorbed := minf(shield, remaining)
		shield -= absorbed
		remaining -= absorbed
		shield_changed.emit(shield)
	if remaining > 0.0:
		current_health = maxf(current_health - remaining, 0.0)
		health_changed.emit(current_health, max_health)
		if current_health <= 0.0:
			die()

func heal(amount: float) -> void:
	current_health = minf(current_health + amount, max_health)
	health_changed.emit(current_health, max_health)

func add_shield(amount: float, duration: float = 0.0) -> void:
	shield += amount
	shield_changed.emit(shield)
	if duration > 0.0:
		get_tree().create_timer(duration).timeout.connect(_expire_shield.bind(amount))

func _expire_shield(amount: float) -> void:
	shield = maxf(shield - amount, 0.0)
	shield_changed.emit(shield)

func die() -> void:
	died.emit()
