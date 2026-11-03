class_name GenericEnemy
extends CharacterBody2D

@export var enemy_id: String = "generic"
@export var max_hp: float = 20.0
@export var speed: float = 90.0
@export var attack_damage: float = 2.0
@export var defense: float = 0.0

var current_hp: float = 20.0
var is_dead: bool = false
var target: Node2D = null
var buff_manager: BuffManager = null

# Animation / Frame stepping
var frame_timer: float = 0.0
var frame_duration: float = 0.12

# 특수 스킬(버프/디버프) 관련 설정
var buff_skill_interval: float = 0.0
var buff_skill_timer: float = 0.0
var buff_to_self: String = ""
var debuff_to_player_aura: String = ""
var debuff_on_hit: String = ""
var impact_color: String = "yellow"

@onready var sprite: Sprite2D = $Sprite2D
@onready var col_shape: CollisionShape2D = $CollisionShape2D
@onready var hit_col_shape: CollisionShape2D = $HitBox/CollisionShape2D

func _ready() -> void:
	add_to_group("enemies")
	buff_manager = BuffManager.new()
	buff_manager.name = "BuffManager"
	add_child(buff_manager)
	current_hp = max_hp
	_find_player()

func _find_player() -> void:
	if not is_inside_tree():
		return
	var tree = get_tree()
	if not tree:
		return
	var players = tree.get_nodes_in_group("player")
	if players.size() > 0:
		target = players[0]

func _physics_process(delta: float) -> void:
	if is_dead:
		return
	
	if buff_manager and (buff_manager.is_stunned or buff_manager.is_frozen):
		velocity = Vector2.ZERO
		return
	
	if not target or not is_instance_valid(target):
		_find_player()
		return
	
	_process_enemy_skills(delta)
	
	var dir = (target.global_position - global_position).normalized()
	var effective_speed = speed
	if buff_manager:
		effective_speed *= buff_manager.get_speed_multiplier()
	velocity = dir * effective_speed
	move_and_slide()
	
	if dir.x > 0:
		sprite.flip_h = false
	elif dir.x < 0:
		sprite.flip_h = true
	
	# Frame animation cycle
	if sprite and sprite.hframes > 1:
		frame_timer += delta
		if frame_timer >= frame_duration:
			frame_timer = 0.0
			sprite.frame = (sprite.frame + 1) % sprite.hframes

func _process_enemy_skills(delta: float) -> void:
	# 1) 자가 버프 시전 주기
	if buff_skill_interval > 0.0 and buff_to_self != "":
		buff_skill_timer += delta
		if buff_skill_timer >= buff_skill_interval:
			buff_skill_timer = 0.0
			_cast_self_buff()
	
	# 2) 플레이어 근접 오라 디버프 (거리 160px 이내 접근 시)
	if debuff_to_player_aura != "" and target and is_instance_valid(target):
		var dist = global_position.distance_to(target.global_position)
		if dist < 160.0 and target.has_method("add_buff"):
			target.add_buff(debuff_to_player_aura, 2.5)

func _cast_self_buff() -> void:
	if buff_manager and buff_to_self != "":
		buff_manager.apply_buff(buff_to_self, 5.0)
		# 버프 시전 임팩트 효과
		ObjectPool.spawn_impact_effect(global_position, impact_color, Vector2(1.8, 1.8))

func take_damage(amount: float) -> void:
	if is_dead:
		return
	
	var effective_def = defense
	if buff_manager:
		effective_def = (effective_def + buff_manager.get_defense_addition()) * buff_manager.get_defense_multiplier()
		
	var actual_dmg = max(1.0, amount - effective_def)
	if buff_manager:
		actual_dmg *= (1.0 - buff_manager.get_damage_reduction() + buff_manager.get_damage_amplify())
		actual_dmg = max(1.0, actual_dmg)
		
	current_hp -= actual_dmg
	
	modulate = Color(2.0, 0.3, 0.3)
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.1)
	
	if current_hp <= 0:
		die()

func add_buff(buff_id: String, duration: float = -1.0, stacks: int = 1) -> void:
	if buff_manager:
		buff_manager.apply_buff(buff_id, duration, stacks)

func setup_enemy(cfg: Dictionary, pos: Vector2) -> void:
	global_position = pos
	is_dead = false
	modulate = Color.WHITE
	visible = true
	set_physics_process(true)
	
	enemy_id = cfg.get("id", "enemy")
	max_hp = cfg.get("hp", 20.0)
	current_hp = max_hp
	speed = cfg.get("speed", 90.0)
	attack_damage = cfg.get("damage", 2.0)
	defense = cfg.get("defense", 0.0)
	scale = cfg.get("scale", Vector2(1.5, 1.5))
	
	# 버프 / 디버프 스킬 파라미터 주입
	buff_to_self = cfg.get("buff_to_self", "")
	buff_skill_interval = cfg.get("buff_interval", 0.0)
	buff_skill_timer = randf_range(1.0, max(2.0, buff_skill_interval))
	debuff_to_player_aura = cfg.get("aura_debuff", "")
	debuff_on_hit = cfg.get("hit_debuff", "")
	impact_color = cfg.get("impact_color", "yellow")
	
	if sprite:
		if cfg.has("texture"):
			sprite.texture = cfg["texture"]
		if cfg.has("hframes"):
			sprite.hframes = cfg["hframes"]
		sprite.frame = 0
	
	frame_timer = 0.0
	
	if buff_manager:
		buff_manager.clear_all_buffs()
	_find_player()

func die() -> void:
	if is_dead:
		return
	is_dead = true
	
	# 사망 시 임팩트 이펙트 소환
	ObjectPool.spawn_impact_effect(global_position, impact_color, Vector2(1.6, 1.6))
	
	if is_inside_tree() and get_tree():
		var chapter = get_tree().current_scene
		if chapter and chapter.has_method("on_enemy_killed"):
			chapter.on_enemy_killed(enemy_id, global_position)
	
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.15)
	tween.tween_callback(recycle)

func recycle() -> void:
	if buff_manager:
		buff_manager.clear_all_buffs()
	set_physics_process(false)
	visible = false
	ObjectPool.return_generic_enemy(self)

func _on_hit_box_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and body.has_method("take_damage"):
		var effective_damage = attack_damage
		if buff_manager:
			effective_damage = (effective_damage + buff_manager.get_attack_addition()) * buff_manager.get_attack_multiplier()
		body.take_damage(effective_damage)
		
		# 공격 적중 시 플레이어에게 상태이상 디버프 부여
		if debuff_on_hit != "" and body.has_method("add_buff"):
			body.add_buff(debuff_on_hit, 4.0)
