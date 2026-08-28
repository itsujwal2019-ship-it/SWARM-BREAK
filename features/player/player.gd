class_name Player
extends CharacterBody2D

signal player_died

@export var movement_speed: float = 300.0
@export var character_definition: CharacterDefinition = null

@onready var health_component: HealthComponent = $HealthComponent
@onready var ability_controller: AbilityController = $AbilityController

func _ready() -> void:
	add_to_group("player")
	add_to_group("allies")
	health_component.died.connect(_on_died)

	if character_definition:
		apply_character(character_definition)

func _physics_process(_delta: float) -> void:
	var input_dir := Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down")
	).normalized()
	velocity = input_dir * movement_speed
	move_and_slide()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ability_1"):
		ability_controller.use_ability_1()
	if Input.is_action_just_pressed("ability_2"):
		ability_controller.use_ability_2()

func apply_character(def: CharacterDefinition) -> void:
	character_definition = def
	movement_speed = def.movement_speed
	health_component.max_health = def.max_health
	health_component.current_health = def.max_health
	health_component.shield = 0.0
	ability_controller.setup(def)

func take_damage(amount: float) -> void:
	health_component.take_damage(amount)

func heal(amount: float) -> void:
	health_component.heal(amount)

func get_health_ratio() -> float:
	return health_component.current_health / health_component.max_health

func get_aim_direction() -> Vector2:
	return (get_global_mouse_position() - global_position).normalized()

func _on_died() -> void:
	player_died.emit()
	set_physics_process(false)
	set_process(false)
	hide()
