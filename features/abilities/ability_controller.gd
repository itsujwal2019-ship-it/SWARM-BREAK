class_name AbilityController
extends Node

var _ability_1: Ability = null
var _ability_2: Ability = null
var _owner_node: Node2D

func _ready() -> void:
	_owner_node = get_parent() as Node2D

func setup(char_def: CharacterDefinition) -> void:
	_ability_1 = char_def.ability_1.duplicate() if char_def.ability_1 else null
	_ability_2 = char_def.ability_2.duplicate() if char_def.ability_2 else null

func _process(delta: float) -> void:
	if _ability_1:
		_ability_1.tick(delta)
	if _ability_2:
		_ability_2.tick(delta)

func use_ability_1() -> void:
	if _ability_1:
		_ability_1.activate(_owner_node)

func use_ability_2() -> void:
	if _ability_2:
		_ability_2.activate(_owner_node)

func get_ability_1() -> Ability:
	return _ability_1

func get_ability_2() -> Ability:
	return _ability_2
