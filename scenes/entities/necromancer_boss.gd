class_name NecromancerBoss
extends CharacterBody2D

signal hp_changed(current: float, maximum: float)
signal boss_died
signal buff_applied(stacks: int, multiplier: float)

@export var max_hp: float = 100000000000.0
@export var speed: float = 95.0
@export var min_attack_damage: float = 650.0
@export var hp_percent_damage: float = 0.10
@export var defense: float = 25.0

# 버프 시스템 (1분 버틸 때마다 전체 강화 버프 1%씩 중첩)
var base_max_hp: float = 100000000000.0
var base_speed: float = 95.0
var base_min_damage: float = 650.0
var base_defense: float = 25.0
var buff_stacks: int = 0
var alive_time: float = 0.0

var current_hp: float = 100000000000.0
var is_dead: bool = false
var target: Node2D = null

# 대쉬 스킬 상태 변수
enum BossState { CHASE, TELEGRAPH, DASH, RECOVERY }
var state: BossState = BossState.CHASE

var dash_cooldown: float = 5.0
var dash_timer: float = 3.0 # 스폰 후 3초 뒤 첫 대쉬 시도
var dash_direction: Vector2 = Vector2.ZERO
var state_time: float = 0.0

const TELEGRAPH_DURATION: float = 0.8
const DASH_DURATION: float = 0.45
const DASH_SPEED: float = 520.0
const RECOVERY_DURATION: float = 0.6

@onready var sprite: Sprite2D = $Sprite2D
@onready var hp_bar: ProgressBar = $HPBar

func _ready() -> void:
	add_to_group("enemies")
	base_max_hp = max_hp
	base_speed = speed
	base_min_damage = min_attack_damage
	base_defense = defense
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

func _physics_process(delta: float) -> void:
	if is_dead:
		return
	
	_process_buff(delta)
	
	if not target or not is_instance_valid(target):
		_find_player()
		return
	
	match state:
		BossState.CHASE:
			_process_chase(delta)
		BossState.TELEGRAPH:
			_process_telegraph(delta)
		BossState.DASH:
			_process_dash(delta)
		BossState.RECOVERY:
			_process_recovery(delta)

func _process_buff(delta: float) -> void:
	alive_time += delta
	var expected_stacks = int(alive_time / 60.0)
	if expected_stacks > buff_stacks:
		buff_stacks = expected_stacks
		_apply_buff_stack()

func _apply_buff_stack() -> void:
	# 1분당 1%씩 전체 강화 (공격력, 최대체력, 이동속도, 방어력)
	var buff_mult = 1.0 + (buff_stacks * 0.01)
	
	var old_max_hp = max_hp
	max_hp = base_max_hp * buff_mult
	# 체력 비율 유지 증가
	if old_max_hp > 0.0:
		var hp_ratio = current_hp / old_max_hp
		current_hp = max_hp * hp_ratio
	else:
		current_hp = max_hp
	
	speed = base_speed * buff_mult
	min_attack_damage = base_min_damage * buff_mult
	defense = base_defense * buff_mult
	
	if hp_bar:
		hp_bar.max_value = max_hp
		hp_bar.value = current_hp
	
	hp_changed.emit(current_hp, max_hp)
	buff_applied.emit(buff_stacks, buff_mult)
	
	# 버프 획득 시 붉은 황금빛 강화 이펙트 번쩍임
	modulate = Color(3.0, 1.8, 0.5, 1.0)
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.4)

func _process_chase(delta: float) -> void:
	dash_timer -= delta
	var to_target = (target.global_position - global_position)
	var dist = to_target.length()
	var dir = to_target.normalized()
	
	velocity = dir * speed
	move_and_slide()
	_update_facing(dir.x)
	
	# 대쉬 조건: 쿨다운 완료 및 플레이어와의 거리가 사거리 내 (100~650px)
	if dash_timer <= 0.0 and dist > 80.0 and dist < 700.0:
		_start_telegraph(dir)

func _start_telegraph(dir: Vector2) -> void:
	state = BossState.TELEGRAPH
	state_time = 0.0
	dash_direction = dir
	velocity = Vector2.ZERO
	_update_facing(dash_direction.x)
	# 대쉬 준비 전조: 붉은/보라색 점멸
	modulate = Color(2.5, 0.4, 0.4, 1.0)

func _process_telegraph(delta: float) -> void:
	state_time += delta
	# 대쉬 직전까지 플레이어를 조준
	if target and is_instance_valid(target):
		dash_direction = (target.global_position - global_position).normalized()
		_update_facing(dash_direction.x)
	
	# 진동 효과
	position += Vector2(randf_range(-1.5, 1.5), randf_range(-1.5, 1.5))
	
	if state_time >= TELEGRAPH_DURATION:
		_start_dash()

func _start_dash() -> void:
	state = BossState.DASH
	state_time = 0.0
	velocity = dash_direction * DASH_SPEED
	# 대쉬 중 잔상 효과 색상 (암흑 마법 보라빛)
	modulate = Color(1.8, 0.3, 2.5, 1.0)

func _process_dash(delta: float) -> void:
	state_time += delta
	move_and_slide()
	
	if state_time >= DASH_DURATION:
		_start_recovery()

func _start_recovery() -> void:
	state = BossState.RECOVERY
	state_time = 0.0
	velocity = Vector2.ZERO
	modulate = Color(0.8, 0.8, 0.8, 1.0)

func _process_recovery(delta: float) -> void:
	state_time += delta
	if state_time >= RECOVERY_DURATION:
		state = BossState.CHASE
		dash_timer = dash_cooldown
		modulate = Color.WHITE

func _update_facing(dir_x: float) -> void:
	if dir_x > 0:
		sprite.flip_h = false
	elif dir_x < 0:
		sprite.flip_h = true

func _calculate_attack_damage(player_node: Node2D) -> float:
	var target_max_hp: float = 100.0
	if "stats" in player_node and player_node.stats != null:
		target_max_hp = player_node.stats.max_hp
	elif "max_hp" in player_node:
		target_max_hp = player_node.max_hp
	
	var hp_based_damage = target_max_hp * hp_percent_damage
	# 최소 650 또는 플레이어 최대 체력의 10% 중 더 큰 값
	return max(min_attack_damage, hp_based_damage)

func take_damage(amount: float) -> void:
	if is_dead:
		return
	
	var actual_dmg = max(1.0, amount - defense)
	current_hp -= actual_dmg
	if hp_bar:
		hp_bar.value = current_hp
	hp_changed.emit(current_hp, max_hp)
	
	modulate = Color(2.0, 0.2, 0.2)
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.WHITE if state == BossState.CHASE else Color(1.8, 0.3, 2.5), 0.15)
	
	if current_hp <= 0:
		die()

func die() -> void:
	if is_dead:
		return
	is_dead = true
	boss_died.emit()
	
	var chapter = get_tree().current_scene
	if chapter and chapter.has_method("on_enemy_killed"):
		chapter.on_enemy_killed("necromancer", global_position)
	if chapter and chapter.has_method("spawn_boss_rewards"):
		chapter.spawn_boss_rewards(global_position)
	
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	tween.tween_callback(queue_free)

func _on_hit_box_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and body.has_method("take_damage"):
		var damage_to_deal = _calculate_attack_damage(body)
		body.take_damage(damage_to_deal)
		
		# 보스 피격 시 디버프 부여 (이동속도 50% 둔화 / 3.0초)
		if body.has_method("apply_debuff"):
			body.apply_debuff(0.5, 3.0)
