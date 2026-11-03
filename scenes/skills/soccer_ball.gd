class_name SoccerBall
extends Area2D

@export var speed: float = 550.0
@export var damage: float = 35.0
@export var bounces_left: int = 5

var velocity: Vector2 = Vector2.RIGHT

func _ready() -> void:
	collision_layer = 4
	collision_mask = 2
	body_entered.connect(_on_body_entered)

func launch(dir: Vector2, dmg: float) -> void:
	velocity = dir.normalized() * speed
	damage = dmg

func _physics_process(delta: float) -> void:
	position += velocity * delta
	rotation += 12.0 * delta

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies") and body.has_method("take_damage"):
		body.take_damage(damage)
		bounces_left -= 1
		# Bounce in slightly changed direction
		var rand_angle = randf_range(PI * 0.4, PI * 0.8) * (1 if randf() > 0.5 else -1)
		velocity = velocity.rotated(rand_angle)
		if bounces_left <= 0:
			queue_free()
