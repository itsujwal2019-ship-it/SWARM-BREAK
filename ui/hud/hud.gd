class_name HUD
extends CanvasLayer

@onready var character_label: Label = $Root/TopBar/LeftInfo/CharacterLabel
@onready var health_bar: ProgressBar = $Root/TopBar/LeftInfo/HealthRow/HealthBar
@onready var health_nums: Label = $Root/TopBar/LeftInfo/HealthRow/HealthNums
@onready var shield_label: Label = $Root/TopBar/LeftInfo/ShieldLabel
@onready var time_label: Label = $Root/TopBar/RightInfo/TimeLabel
@onready var kills_label: Label = $Root/TopBar/RightInfo/KillsLabel
@onready var ability1_label: Label = $Root/BottomBar/Ability1Label
@onready var ability2_label: Label = $Root/BottomBar/Ability2Label
@onready var effects_label: Label = $Root/BottomBar/EffectsLabel

func update_health(current: float, max_hp: float) -> void:
	health_bar.value = (current / max_hp) * 100.0 if max_hp > 0 else 0.0
	health_nums.text = "%d / %d" % [int(current), int(max_hp)]

func update_shield(amount: float) -> void:
	if amount > 0.0:
		shield_label.text = "Shield: %d" % int(amount)
		shield_label.show()
	else:
		shield_label.hide()

func update_character(display_name: String) -> void:
	character_label.text = display_name

func update_abilities(a1: Ability, a2: Ability) -> void:
	ability1_label.text = _fmt_ability("1", a1)
	ability2_label.text = _fmt_ability("2", a2)

func _fmt_ability(slot: String, ability: Ability) -> String:
	if ability == null:
		return "[%s] —" % slot
	var name_part := "[%s] %s" % [slot, ability.ability_name]
	if ability.can_activate():
		return name_part + "  ✓"
	return name_part + "  %.1fs" % ability.get_remaining_cooldown()

func update_active_effects(hot_remaining: float) -> void:
	var parts: Array[String] = []
	if hot_remaining > 0.0:
		parts.append("Healing: %.1fs" % hot_remaining)
	if parts.is_empty():
		effects_label.hide()
	else:
		effects_label.text = "  ".join(parts)
		effects_label.show()

func update_time(seconds: float) -> void:
	var m := int(seconds / 60.0)
	var s := int(seconds) - m * 60
	time_label.text = "TIME: %02d:%02d" % [m, s]

func update_kills(count: int) -> void:
	kills_label.text = "KILLS: " + str(count)
