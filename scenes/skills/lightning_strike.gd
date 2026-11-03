class_name LightningStrike
extends Node2D

@export var damage: float = 40.0

func _ready() -> void:
	# Flash vertical lightning strike
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.05)
	tween.tween_property(self, "modulate:a", 0.0, 0.25)
	tween.tween_callback(queue_free)

func strike_target(enemy: Node2D, dmg: float) -> void:
	damage = dmg
	if is_instance_valid(enemy):
		global_position = enemy.global_position
		if enemy.has_method("take_damage"):
			enemy.take_damage(damage)
