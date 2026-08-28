class_name CharacterDefinition
extends Resource

@export var character_id: String = ""
@export var display_name: String = ""
@export var role: CharacterRole.Role = CharacterRole.Role.DAMAGE
@export var max_health: float = 100.0
@export var movement_speed: float = 260.0
@export var ability_1: Ability = null
@export var ability_2: Ability = null
