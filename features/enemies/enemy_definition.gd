class_name EnemyDefinition
extends Resource

enum Behavior { CHASE = 0, RANGED = 1 }

@export var enemy_id: String = ""
@export var display_name: String = ""
@export var max_health: float = 100.0
@export var movement_speed: float = 100.0
@export var contact_damage: float = 10.0
@export var damage_interval: float = 0.5
@export var body_scale: float = 1.0
@export var body_color: Color = Color(1.0, 0.2, 0.2, 1.0)
@export var behavior: Behavior = Behavior.CHASE
@export var spawn_warning_duration: float = 0.8

# Ranged-only — ignored for CHASE enemies
@export var attack_range: float = 400.0
@export var attack_cooldown: float = 2.0
@export var projectile_damage: float = 15.0
@export var preferred_distance: float = 300.0
