class_name Player
extends CharacterBody2D

signal player_died

@export var movement_speed: float = 300.0

@onready var health_component: HealthComponent = $HealthComponent

func _ready() -> void:
	add_to_group("player")
	health_component.died.connect(_on_died)

func _physics_process(_delta: float) -> void:
	var input_dir := Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down")
	).normalized()
	velocity = input_dir * movement_speed
	move_and_slide()

func take_damage(amount: float) -> void:
	health_component.take_damage(amount)

func get_health_ratio() -> float:
	return health_component.current_health / health_component.max_health

func _on_died() -> void:
	player_died.emit()
	set_physics_process(false)
	set_process(false)
	hide()
