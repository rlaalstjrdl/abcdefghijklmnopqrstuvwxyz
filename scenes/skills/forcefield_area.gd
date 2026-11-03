class_name ForcefieldArea
extends Area2D

@export var tick_interval: float = 0.5
@export var base_damage: float = 8.0
@export var radius: float = 70.0

var tick_timer: float = 0.0

@onready var col_shape: CollisionShape2D = $CollisionShape2D
@onready var color_circle: ColorRect = $ColorRect

func _ready() -> void:
	collision_layer = 4
	collision_mask = 2

func set_level(level: int) -> void:
	base_damage = 6.0 + (level * 4.0)
	radius = 65.0 + (level * 15.0)
	if col_shape and col_shape.shape is CircleShape2D:
		col_shape.shape.radius = radius

func _physics_process(delta: float) -> void:
	tick_timer -= delta
	if tick_timer <= 0.0:
		tick_timer = tick_interval
		_damage_enemies_inside()

func _damage_enemies_inside() -> void:
	var bodies = get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("enemies") and body.has_method("take_damage"):
			body.take_damage(base_damage)
			# Brief pulse visual
			modulate = Color(1.5, 1.5, 2.0, 0.7)
			var tween = create_tween()
			tween.tween_property(self, "modulate", Color(1.0, 1.0, 1.0, 0.4), 0.2)
