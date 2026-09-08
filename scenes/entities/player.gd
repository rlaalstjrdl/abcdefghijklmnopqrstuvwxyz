class_name Player
extends CharacterBody2D

@export var stats: CharacterStats
@export var projectile_scene: PackedScene = preload("res://scenes/entities/projectile.tscn")

var current_hp: float = 100.0
var attack_timer: float = 0.0
var is_dead: bool = false
var is_attacking: bool = false

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var detection_area: Area2D = $DetectionArea
@onready var detection_shape: CollisionShape2D = $DetectionArea/CollisionShape2D

signal hp_changed(new_hp, max_hp)
signal player_died

func _ready() -> void:
	if not stats:
		stats = preload("res://resources/skeleton_stats.tres")
	
	current_hp = stats.max_hp
	hp_changed.emit(current_hp, stats.max_hp)
	
	if detection_shape and detection_shape.shape is CircleShape2D:
		detection_shape.shape.radius = stats.attack_range
	
	animated_sprite.play("idle")

func _physics_process(delta: float) -> void:
	if is_dead:
		return
	
	# Handle movement
	var move_vec = SettingsManager.get_movement_vector()
	velocity = move_vec * stats.move_speed
	move_and_slide()
	
	# Update animation and facing
	_update_animation(move_vec)
	
	# Handle attack cooldown
	attack_timer -= delta
	if attack_timer <= 0.0:
		if SettingsManager.auto_attack:
			_check_auto_attack()
		else:
			_check_manual_attack()

func _update_animation(move_vec: Vector2) -> void:
	if is_attacking:
		return
	
	if move_vec.x > 0:
		animated_sprite.flip_h = false
	elif move_vec.x < 0:
		animated_sprite.flip_h = true
	
	if move_vec.length_squared() > 0.01:
		if animated_sprite.animation != "walk":
			animated_sprite.play("walk")
	else:
		if animated_sprite.animation != "idle":
			animated_sprite.play("idle")

func _check_auto_attack() -> void:
	var closest_enemy = _find_closest_enemy()
	if closest_enemy:
		var dir = (closest_enemy.global_position - global_position).normalized()
		_perform_attack(dir)

func _check_manual_attack() -> void:
	if Input.is_action_just_pressed("attack_manual") or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		var mouse_pos = get_global_mouse_position()
		var dir = (mouse_pos - global_position).normalized()
		if dir == Vector2.ZERO:
			dir = Vector2.RIGHT if not animated_sprite.flip_h else Vector2.LEFT
		_perform_attack(dir)

func _find_closest_enemy() -> Node2D:
	var overlapping_bodies = detection_area.get_overlapping_bodies()
	var closest: Node2D = null
	var min_dist: float = stats.attack_range
	
	for body in overlapping_bodies:
		if body.is_in_group("enemies") and not body.get("is_dead"):
			var dist = global_position.distance_to(body.global_position)
			if dist < min_dist:
				min_dist = dist
				closest = body
	
	return closest

func _perform_attack(direction: Vector2) -> void:
	attack_timer = stats.attack_cooldown
	is_attacking = true
	
	if direction.x > 0:
		animated_sprite.flip_h = false
	elif direction.x < 0:
		animated_sprite.flip_h = true
	
	animated_sprite.play("attack")
	
	# Spawn projectile
	if projectile_scene:
		var proj = projectile_scene.instantiate()
		proj.global_position = global_position
		proj.damage = stats.attack_power
		proj.set_target_direction(direction)
		get_parent().add_child(proj)

func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite.animation == "attack":
		is_attacking = false
		animated_sprite.play("idle")
	elif animated_sprite.animation == "hurt":
		is_attacking = false
		animated_sprite.play("idle")
	elif animated_sprite.animation == "death":
		queue_free()

func take_damage(amount: float) -> void:
	if is_dead:
		return
	
	var final_damage = max(1.0, amount - stats.defense)
	current_hp -= final_damage
	hp_changed.emit(current_hp, stats.max_hp)
	
	if current_hp <= 0:
		_die()
	else:
		is_attacking = true
		animated_sprite.play("hurt")

func _die() -> void:
	is_dead = true
	player_died.emit()
	animated_sprite.play("death")
