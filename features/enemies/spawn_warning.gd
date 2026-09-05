extends Node2D

var duration: float = 0.8
var _elapsed: float = 0.0
var _radius: float = 28.0

func _process(delta: float) -> void:
	_elapsed += delta
	queue_redraw()
	if _elapsed >= duration:
		queue_free()

func _draw() -> void:
	var t := clampf(_elapsed / duration, 0.0, 1.0)
	# Filled circle fades out
	var fill_alpha := (1.0 - t) * 0.35
	draw_circle(Vector2.ZERO, _radius, Color(1.0, 0.5, 0.0, fill_alpha))
	# Pulsing ring stays solid
	var ring_alpha := 0.5 + 0.5 * sin(t * TAU * 3.0)
	draw_arc(Vector2.ZERO, _radius, 0.0, TAU, 32, Color(1.0, 0.9, 0.0, ring_alpha), 3.0)
