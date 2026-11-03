class_name Player
extends CharacterBody2D

@export var stats: CharacterStats
@export var projectile_scene: PackedScene = preload("res://scenes/entities/projectile.tscn")

var current_hp: float = 100.0
var attack_timer: float = 0.0
var invulnerable_timer: float = 0.0
var is_dead: bool = false
var is_attacking_anim: bool = false
var skill_manager: Node = null
var buff_manager: BuffManager = null

# 디버프 시스템 (하위 호환 유지)
var debuff_timer: float = 0.0
var speed_multiplier: float = 1.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

signal hp_changed(new_hp: float, max_hp: float)
signal player_died

func _ready() -> void:
	stats = SettingsManager.get_selected_stats()
	current_hp = stats.max_hp
	hp_changed.emit(current_hp, stats.max_hp)
	
	buff_manager = BuffManager.new()
	buff_manager.name = "BuffManager"
	add_child(buff_manager)
	
	var sm_script = preload("res://scenes/skills/skill_manager.gd")
	skill_manager = sm_script.new()
	skill_manager.name = "SkillManager"
	add_child(skill_manager)
	
	scale = Vector2(2.2, 2.2)
	_setup_character_animations(stats.character_id)
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
	_add_anim_frames(frames, "attack", attack_path, 6, 14.0, false)
	_add_anim_frames(frames, "hurt", hurt_path, 4, 10.0, false)
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
	
	if invulnerable_timer > 0.0:
		invulnerable_timer -= delta
	
	# 디버프 타이머 처리
	if debuff_timer > 0.0:
		debuff_timer -= delta
		if debuff_timer <= 0.0:
			speed_multiplier = 1.0
			modulate = Color.WHITE
	
	# Movement
	var move_vec = SettingsManager.get_movement_vector()
	var effective_speed = stats.move_speed * speed_multiplier
	if buff_manager:
		effective_speed *= buff_manager.get_speed_multiplier()
	
	velocity = move_vec * effective_speed
	move_and_slide()
	
	# Animation
	_update_animation(move_vec)
	
	# Attack Cooldown
	attack_timer -= delta
	var can_act = true
	if buff_manager and (buff_manager.is_stunned or buff_manager.is_frozen or buff_manager.is_silenced):
		can_act = false
		
	if attack_timer <= 0.0 and can_act:
		if SettingsManager.auto_attack:
			_check_auto_attack()
		else:
			_check_manual_attack()

func _update_animation(move_vec: Vector2) -> void:
	if move_vec.x > 0:
		animated_sprite.flip_h = false
	elif move_vec.x < 0:
		animated_sprite.flip_h = true
	
	if is_attacking_anim:
		return
	
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
		_fire_attack(dir)

func _check_manual_attack() -> void:
	if Input.is_action_just_pressed("attack_manual") or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		var mouse_pos = get_global_mouse_position()
		var dir = (mouse_pos - global_position).normalized()
		if dir == Vector2.ZERO:
			dir = Vector2.RIGHT if not animated_sprite.flip_h else Vector2.LEFT
		_fire_attack(dir)

func _find_closest_enemy() -> Node2D:
	var enemies = get_tree().get_nodes_in_group("enemies")
	var closest: Node2D = null
	var min_dist: float = stats.attack_range
	
	for enemy in enemies:
		if is_instance_valid(enemy) and enemy.visible and not enemy.get("is_dead"):
			var dist = global_position.distance_to(enemy.global_position)
			if dist <= min_dist:
				min_dist = dist
				closest = enemy
	
	return closest


func _fire_attack(direction: Vector2) -> void:
	var cd = stats.attack_cooldown
	if buff_manager:
		cd *= buff_manager.get_cooldown_multiplier()
	attack_timer = cd
	
	# Flip towards firing direction
	if direction.x > 0:
		animated_sprite.flip_h = false
	elif direction.x < 0:
		animated_sprite.flip_h = true
	
	# If moving, keep walking animation but flash/slash effect; if standing still, play attack animation
	if velocity.length_squared() < 0.01:
		is_attacking_anim = true
		animated_sprite.play("attack")
	
	# Calculate effective attack power
	var atk_power = stats.attack_power
	if buff_manager:
		atk_power = (atk_power + buff_manager.get_attack_addition()) * buff_manager.get_attack_multiplier()
		atk_power *= (1.0 + buff_manager.get_damage_amplify())
		
		# 실명(Blind) 확률 체크
		if buff_manager.blind_chance > 0.0 and randf() < buff_manager.blind_chance:
			return # 빗나감!
	
	# Spawn Projectile via ObjectPool
	ObjectPool.spawn_projectile(global_position, direction, atk_power, get_parent())

func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite.animation == "attack":
		is_attacking_anim = false
		animated_sprite.play("idle")
	elif animated_sprite.animation == "death":
		queue_free()

func take_damage(amount: float) -> void:
	if is_dead or invulnerable_timer > 0.0:
		return
	
	# 회피(Dodge) 체크
	if buff_manager and buff_manager.get_dodge_chance() > 0.0:
		if randf() < buff_manager.get_dodge_chance():
			return # 회피 성공
	
	invulnerable_timer = 0.25 # 무적 시간
	
	var effective_def = stats.defense
	if buff_manager:
		effective_def = (effective_def + buff_manager.get_defense_addition()) * buff_manager.get_defense_multiplier()
		
	var final_damage = max(1.0, amount - effective_def)
	if buff_manager:
		var red = buff_manager.get_damage_reduction()
		var amp = buff_manager.get_damage_amplify()
		final_damage = max(1.0, final_damage * (1.0 - red + amp))
		
	current_hp -= final_damage
	hp_changed.emit(current_hp, stats.max_hp)
	
	# 피격 임팩트 이펙트
	ObjectPool.spawn_impact_effect(global_position, "red", Vector2(1.8, 1.8))
	
	# Red flash without blocking movement/attack
	modulate = Color(2.5, 0.4, 0.4)
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.15)
	
	if current_hp <= 0:
		_die()

func apply_debuff(speed_ratio: float, duration: float) -> void:
	if is_dead:
		return
	speed_multiplier = speed_ratio
	debuff_timer = duration
	# 디버프(저주/둔화) 시 보라색으로 깜빡임 표시
	modulate = Color(0.6, 0.2, 0.9, 1.0)

func add_buff(buff_id: String, duration: float = -1.0, stacks: int = 1) -> void:
	if buff_manager:
		buff_manager.apply_buff(buff_id, duration, stacks)

func remove_buff(buff_id: String) -> void:
	if buff_manager:
		buff_manager.remove_buff(buff_id)

func heal_percent(pct: float) -> void:
	if is_dead:
		return
	var heal_amount = stats.max_hp * pct
	current_hp = min(stats.max_hp, current_hp + heal_amount)
	hp_changed.emit(current_hp, stats.max_hp)
	
	# Green flash for heal
	modulate = Color(0.4, 2.0, 0.4)
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.25)

func get_skill_options() -> Array[Dictionary]:
	if skill_manager and skill_manager.has_method("get_available_upgrade_options"):
		return skill_manager.get_available_upgrade_options()
	return []

func upgrade_skill(skill_id: String) -> void:
	if skill_manager and skill_manager.has_method("upgrade_skill"):
		skill_manager.upgrade_skill(skill_id)

func _die() -> void:
	is_dead = true
	player_died.emit()
	animated_sprite.play("death")
