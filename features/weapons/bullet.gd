class_name Bullet
extends Area2D

@export var speed: float = 800.0
@export var damage: float = 10.0
@export var lifetime: float = 2.0

var direction: Vector2 = Vector2.RIGHT

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)
	get_tree().create_timer(lifetime).timeout.connect(queue_free)

func _physics_process(delta: float) -> void:
	position += direction * speed * delta

func _on_body_entered(_body: Node2D) -> void:
	queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area is HurtboxComponent:
		area.receive_damage(damage)
		queue_free()
