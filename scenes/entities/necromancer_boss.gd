class_name NecromancerBoss
extends CharacterBody2D

@export var max_hp: float = 1000.0
@export var speed: float = 80.0
@export var attack_damage: float = 15.0
@export var defense: float = 25.0

var current_hp: float = 1000.0
var is_dead: bool = false
var target: Node2D = null

@onready var sprite: Sprite2D = $Sprite2D
@onready var hp_bar: ProgressBar = $HPBar

func _ready() -> void:
	add_to_group("enemies")
	current_hp = max_hp
	scale = Vector2(3.0, 3.0)
	if hp_bar:
		hp_bar.max_value = max_hp
		hp_bar.value = current_hp
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
	
	var actual_dmg = max(1.0, amount - defense)
	current_hp -= actual_dmg
	if hp_bar:
		hp_bar.value = current_hp
	
	modulate = Color(2.0, 0.2, 0.2)
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.15)
	
	if current_hp <= 0:
		die()

func die() -> void:
	if is_dead:
		return
	is_dead = true
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	tween.tween_callback(queue_free)

func _on_hit_box_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and body.has_method("take_damage"):
		body.take_damage(attack_damage)
