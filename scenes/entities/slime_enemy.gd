class_name SlimeEnemy
extends CharacterBody2D

@export var split_level: int = 1 # 1 (Max HP 10), 2 (5), 3 (2.5), 4 (1.0)
@export var speed: float = 95.0
@export var attack_damage: float = 1.0
@export var defense: float = 0.0

var max_hp: float = 10.0
var current_hp: float = 10.0
var is_dead: bool = false
var target: Node2D = null

@onready var sprite: Sprite2D = $Sprite2D
@onready var col_shape: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	add_to_group("enemies")
	_setup_stats_by_level()
	_find_player()

func _setup_stats_by_level() -> void:
	match split_level:
		1:
			max_hp = 10.0
			scale = Vector2(2.0, 2.0)
			speed = 90.0
		2:
			max_hp = 5.0
			scale = Vector2(1.5, 1.5)
			speed = 105.0
		3:
			max_hp = 2.5
			scale = Vector2(1.1, 1.1)
			speed = 120.0
		4:
			max_hp = 1.0
			scale = Vector2(0.8, 0.8)
			speed = 135.0
		_:
			max_hp = 1.0
			scale = Vector2(0.7, 0.7)
			speed = 140.0
			
	current_hp = max_hp

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
	
	modulate = Color(1.8, 0.3, 0.3)
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.12)
	
	if current_hp <= 0:
		die()

func die() -> void:
	if is_dead:
		return
	is_dead = true
	
	# Split into 2 if split_level < 4
	if split_level < 4:
		call_deferred("_spawn_split_children")
	
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.15)
	tween.tween_callback(queue_free)

func _spawn_split_children() -> void:
	var slime_scene = load("res://scenes/entities/slime_enemy.tscn")
	if not slime_scene:
		return
	
	for i in range(2):
		var child_slime: SlimeEnemy = slime_scene.instantiate()
		child_slime.split_level = split_level + 1
		var offset = Vector2(randf_range(-18, 18), randf_range(-18, 18))
		child_slime.global_position = global_position + offset
		get_parent().add_child(child_slime)

func _on_hit_box_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and body.has_method("take_damage"):
		body.take_damage(attack_damage)
