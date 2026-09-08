class_name Enemy
extends CharacterBody2D

@export var max_hp: float = 40.0
@export var speed: float = 90.0
@export var attack_damage: float = 10.0

var current_hp: float
var is_dead: bool = false
var target: Node2D = null

@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	add_to_group("enemies")
	current_hp = max_hp
	_find_player()

func _find_player() -> void:
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		target = players[0]

func _physics_process(_delta: float) -> void:
	if is_dead:
		return
	
	if not target or not is_instance_valid(target):
		_find_player()
		return
	
	var dir = (target.global_position - global_position).normalized()
	velocity = dir * speed
	move_and_slide()
	
	if dir.x > 0:
		sprite.flip_h = false
	elif dir.x < 0:
		sprite.flip_h = true

func take_damage(amount: float) -> void:
	if is_dead:
		return
	
	current_hp -= amount
	# Simple hit flash
	modulate = Color(1.5, 0.4, 0.4)
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.15)
	
	if current_hp <= 0:
		die()

func die() -> void:
	is_dead = true
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.2)
	tween.tween_callback(queue_free)

func _on_hit_box_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and body.has_method("take_damage"):
		body.take_damage(attack_damage)
