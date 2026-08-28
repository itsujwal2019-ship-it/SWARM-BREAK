class_name WeaponHolder
extends Node2D

var _weapon: Weapon

func _ready() -> void:
	_weapon = get_child(0) as Weapon

func _process(_delta: float) -> void:
	var mouse_pos := get_global_mouse_position()
	var aim_dir := (mouse_pos - global_position).normalized()
	rotation = aim_dir.angle()

	if Input.is_action_pressed("shoot") and _weapon:
		_weapon.shoot(aim_dir)
