class_name ImpactEffect
extends AnimatedSprite2D

func _ready() -> void:
	if not animation_finished.is_connected(_on_animation_finished):
		animation_finished.connect(_on_animation_finished)

func play_impact(pos: Vector2, color_type: String = "yellow", scale_val: Vector2 = Vector2(1.5, 1.5)) -> void:
	global_position = pos
	scale = scale_val
	visible = true
	
	if not sprite_frames or not sprite_frames.has_animation(color_type):
		color_type = "yellow"
		
	if sprite_frames and sprite_frames.has_animation(color_type):
		play(color_type)
	else:
		visible = false
		ObjectPool.return_impact_effect(self)

func _on_animation_finished() -> void:
	visible = false
	ObjectPool.return_impact_effect(self)
