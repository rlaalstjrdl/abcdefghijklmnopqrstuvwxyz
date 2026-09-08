class_name Player
extends CharacterBody2D

@export var stats: CharacterStats
@export var projectile_scene: PackedScene = preload("res://scenes/entities/projectile.tscn")

var current_hp: float = 100.0
var attack_timer: float = 0.0
var is_dead: bool = false
var is_attacking: bool = false
var pending_attack_dir: Vector2 = Vector2.RIGHT
var has_spawned_projectile_in_attack: bool = false

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

signal hp_changed(new_hp, max_hp)
signal player_died

func _ready() -> void:
	# Load selected commando stats
	stats = SettingsManager.get_selected_stats()
	current_hp = stats.max_hp
	hp_changed.emit(current_hp, stats.max_hp)
	
	# Increase size
	scale = Vector2(2.2, 2.2)
	
	_setup_character_animations(stats.character_id)
	
	if not animated_sprite.frame_changed.is_connected(_on_sprite_frame_changed):
		animated_sprite.frame_changed.connect(_on_sprite_frame_changed)
	
	animated_sprite.play("idle")

func _setup_character_animations(char_id: String) -> void:
	var base_folder = "Skeleton"
	if char_id == "soldier":
		base_folder = "Soldier"
	elif char_id == "knight":
		base_folder = "Knight"
	
	var idle_path = "res://assets/ch1/Characters(100x100 split)/%s/%s/%s_Idle.png" % [base_folder, base_folder, base_folder]
	var walk_path = "res://assets/ch1/Characters(100x100 split)/%s/%s/%s_Walk.png" % [base_folder, base_folder, base_folder]
	var attack_path = "res://assets/ch1/Characters(100x100 split)/%s/%s/%s_Attack01.png" % [base_folder, base_folder, base_folder]
	var hurt_path = "res://assets/ch1/Characters(100x100 split)/%s/%s/%s_Hurt.png" % [base_folder, base_folder, base_folder]
	var death_path = "res://assets/ch1/Characters(100x100 split)/%s/%s/%s_Death.png" % [base_folder, base_folder, base_folder]
	
	var frames = SpriteFrames.new()
	_add_anim_frames(frames, "idle", idle_path, 6, 8.0, true)
	_add_anim_frames(frames, "walk", walk_path, 8, 10.0, true)
	_add_anim_frames(frames, "attack", attack_path, 6, 12.0, false)
	_add_anim_frames(frames, "hurt", hurt_path, 4, 8.0, false)
	_add_anim_frames(frames, "death", death_path, 4, 6.0, false)
	
	animated_sprite.sprite_frames = frames

func _add_anim_frames(sf: SpriteFrames, anim_name: String, path: String, frame_count: int, fps: float, loop: bool) -> void:
	if not ResourceLoader.exists(path):
		return
	var tex = load(path) as Texture2D
	if not tex:
		return
	
	if not sf.has_animation(anim_name):
		sf.add_animation(anim_name)
	sf.set_animation_speed(anim_name, fps)
	sf.set_animation_loop(anim_name, loop)
	
	for i in range(frame_count):
		var atlas = AtlasTexture.new()
		atlas.atlas = tex
		atlas.region = Rect2(i * 100, 0, 100, 100)
		sf.add_frame(anim_name, atlas)

func _physics_process(delta: float) -> void:
	if is_dead:
		return
	
	# Movement
	var move_vec = SettingsManager.get_movement_vector()
	velocity = move_vec * stats.move_speed
	move_and_slide()
	
	# Update animation and facing
	_update_animation(move_vec)
	
	# Attack cooldown
	attack_timer -= delta
	if attack_timer <= 0.0 and not is_attacking:
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
		_start_attack(dir)

func _check_manual_attack() -> void:
	if Input.is_action_just_pressed("attack_manual") or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		var mouse_pos = get_global_mouse_position()
		var dir = (mouse_pos - global_position).normalized()
		if dir == Vector2.ZERO:
			dir = Vector2.RIGHT if not animated_sprite.flip_h else Vector2.LEFT
		_start_attack(dir)

func _find_closest_enemy() -> Node2D:
	var enemies = get_tree().get_nodes_in_group("enemies")
	var closest: Node2D = null
	var min_dist: float = stats.attack_range
	
	for enemy in enemies:
		if is_instance_valid(enemy) and not enemy.get("is_dead"):
			var dist = global_position.distance_to(enemy.global_position)
			if dist <= min_dist:
				min_dist = dist
				closest = enemy
	
	return closest

func _start_attack(direction: Vector2) -> void:
	attack_timer = stats.attack_cooldown
	is_attacking = true
	pending_attack_dir = direction
	has_spawned_projectile_in_attack = false
	
	if direction.x > 0:
		animated_sprite.flip_h = false
	elif direction.x < 0:
		animated_sprite.flip_h = true
	
	animated_sprite.stop()
	animated_sprite.play("attack")

func _on_sprite_frame_changed() -> void:
	if is_attacking and animated_sprite.animation == "attack":
		# Attack motion strikes at frame 2
		if animated_sprite.frame >= 2 and not has_spawned_projectile_in_attack:
			_spawn_projectile()

func _spawn_projectile() -> void:
	has_spawned_projectile_in_attack = true
	if projectile_scene:
		var proj = projectile_scene.instantiate()
		proj.global_position = global_position
		proj.damage = stats.attack_power
		proj.set_target_direction(pending_attack_dir)
		get_parent().add_child(proj)

func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite.animation == "attack":
		if not has_spawned_projectile_in_attack:
			_spawn_projectile()
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
