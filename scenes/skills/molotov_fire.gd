class_name MolotovFire
extends Area2D

@export var damage_per_sec: float = 20.0
@export var duration: float = 3.5
@export var tick_interval: float = 0.4

var tick_timer: float = 0.0

func _ready() -> void:
	collision_layer = 4
	collision_mask = 2
	get_tree().create_timer(duration).timeout.connect(queue_free)

func _physics_process(delta: float) -> void:
	tick_timer -= delta
	if tick_timer <= 0.0:
		tick_timer = tick_interval
		for body in get_overlapping_bodies():
			if body.is_in_group("enemies") and body.has_method("take_damage"):
				body.take_damage(damage_per_sec * tick_interval)
