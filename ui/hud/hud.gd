class_name HUD
extends CanvasLayer

@onready var health_bar: ProgressBar = $MarginContainer/HBoxContainer/HealthBar
@onready var time_label: Label = $MarginContainer/HBoxContainer/RightVBox/TimeLabel
@onready var kills_label: Label = $MarginContainer/HBoxContainer/RightVBox/KillsLabel

func update_health(ratio: float) -> void:
	health_bar.value = ratio * 100.0

func update_time(seconds: float) -> void:
	var m := int(seconds / 60.0)
	var s := int(seconds) - m * 60
	time_label.text = "TIME: %02d:%02d" % [m, s]

func update_kills(count: int) -> void:
	kills_label.text = "KILLS: " + str(count)
