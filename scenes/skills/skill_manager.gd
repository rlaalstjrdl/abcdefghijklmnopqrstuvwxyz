class_name SkillManager
extends Node

var active_skills: Dictionary = {}  # skill_id -> level (1~5)
var passive_skills: Dictionary = {} # skill_id -> level (1~5)

# Weapon Timers
var lightning_timer: float = 0.0
var molotov_timer: float = 0.0
var soccer_timer: float = 0.0
var rocket_timer: float = 0.0
var kunai_timer: float = 0.0

var guardian_instance: Node2D = null
var forcefield_instance: Node2D = null

@onready var player: Node2D = get_parent()

# Skill database definition
const SKILL_DEFS: Dictionary = {
	# --- 무기 스킬 ---
	"guardian": {
		"id": "guardian", "name": "수호자", "icon": "🛡️", "type": "weapon",
		"desc": "주변을 회전하며 적을 밀어내고 피해를 줍니다."
	},
	"forcefield": {
		"id": "forcefield", "name": "방어막", "icon": "⚡", "type": "weapon",
		"desc": "플레이어 주변에 지속 피해를 입히는 역장을 생성합니다."
	},
	"lightning": {
		"id": "lightning", "name": "번개 발사기", "icon": "🌩️", "type": "weapon",
		"desc": "주변 적에게 무작위 벼락을 내리꽂아 큰 피해를 입힙니다."
	},
	"molotov": {
		"id": "molotov", "name": "화염병", "icon": "🔥", "type": "weapon",
		"desc": "지면에 화염 장판을 던져 지속 화염 피해를 줍니다."
	},
	"soccer": {
		"id": "soccer", "name": "축구공", "icon": "⚽", "type": "weapon",
		"desc": "적 사이를 고속으로 튕겨 다니며 관통 타격을 입힙니다."
	},
	"kunai": {
		"id": "kunai", "name": "쿠나이", "icon": "🗡️", "type": "weapon",
		"desc": "가장 가까운 적을 향해 빠른 표창을 연속 발사합니다."
	},
	
	# --- 지원(패시브) 스킬 ---
	"bullet": {
		"id": "bullet", "name": "고화력 총알", "icon": "💥", "type": "passive",
		"desc": "모든 공격의 공격력이 15% 증가합니다."
	},
	"cube": {
		"id": "cube", "name": "에너지 큐브", "icon": "🧊", "type": "passive",
		"desc": "모든 무기의 공격 쿨다운이 10% 감소합니다."
	},
	"fuel": {
		"id": "fuel", "name": "고성능 연료", "icon": "⛽", "type": "passive",
		"desc": "공격 사거리와 범위가 15% 증가합니다."
	},
	"shoes": {
		"id": "shoes", "name": "운동화", "icon": "👟", "type": "passive",
		"desc": "이동 속도가 12% 증가합니다."
	},
	"fitness": {
		"id": "fitness", "name": "피트니스 안내서", "icon": "💖", "type": "passive",
		"desc": "최대 체력이 25% 증가하고 체력을 일부 회복합니다."
	},
	"armor": {
		"id": "armor", "name": "부랑자의 갑옷", "icon": "🥋", "type": "passive",
		"desc": "받는 피해가 3 감소합니다."
	}
}

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	if not player or player.is_dead:
		return
	
	# Process timers for active weapon skills
	if active_skills.has("lightning"):
		lightning_timer -= delta
		if lightning_timer <= 0.0:
			lightning_timer = max(0.6, 2.0 - (active_skills["lightning"] * 0.25))
			_cast_lightning(active_skills["lightning"])
	
	if active_skills.has("molotov"):
		molotov_timer -= delta
		if molotov_timer <= 0.0:
			molotov_timer = max(0.8, 2.5 - (active_skills["molotov"] * 0.3))
			_cast_molotov(active_skills["molotov"])
	
	if active_skills.has("soccer"):
		soccer_timer -= delta
		if soccer_timer <= 0.0:
			soccer_timer = max(0.8, 2.2 - (active_skills["soccer"] * 0.25))
			_cast_soccer(active_skills["soccer"])
	
	if active_skills.has("kunai"):
		kunai_timer -= delta
		if kunai_timer <= 0.0:
			kunai_timer = max(0.2, 0.7 - (active_skills["kunai"] * 0.1))
			_cast_kunai(active_skills["kunai"])

func upgrade_skill(skill_id: String) -> void:
	if not SKILL_DEFS.has(skill_id):
		return
	
	var def = SKILL_DEFS[skill_id]
	if def.type == "weapon":
		var cur_lv = active_skills.get(skill_id, 0)
		active_skills[skill_id] = min(5, cur_lv + 1)
		_apply_weapon_upgrade(skill_id, active_skills[skill_id])
	else:
		var cur_lv = passive_skills.get(skill_id, 0)
		passive_skills[skill_id] = min(5, cur_lv + 1)
		_apply_passive_upgrade(skill_id, passive_skills[skill_id])

func _apply_weapon_upgrade(skill_id: String, level: int) -> void:
	match skill_id:
		"guardian":
			if not guardian_instance or not is_instance_valid(guardian_instance):
				var guardian_scene = load("res://scenes/skills/guardian_orbit.gd")
				guardian_instance = Node2D.new()
				guardian_instance.set_script(guardian_scene)
				player.add_child(guardian_instance)
			if guardian_instance.has_method("set_level"):
				guardian_instance.set_level(level)
		"forcefield":
			if not forcefield_instance or not is_instance_valid(forcefield_instance):
				var ff_scene = load("res://scenes/skills/forcefield_area.tscn")
				if ff_scene:
					forcefield_instance = ff_scene.instantiate()
					player.add_child(forcefield_instance)
			if forcefield_instance and forcefield_instance.has_method("set_level"):
				forcefield_instance.set_level(level)

func _apply_passive_upgrade(skill_id: String, _level: int) -> void:
	if not player or not player.stats:
		return
	
	match skill_id:
		"bullet":
			player.stats.attack_power *= 1.15
		"cube":
			player.stats.attack_cooldown = max(0.2, player.stats.attack_cooldown * 0.9)
		"fuel":
			player.stats.attack_range *= 1.15
		"shoes":
			player.stats.move_speed *= 1.12
		"fitness":
			player.stats.max_hp *= 1.25
			player.heal_percent(0.3)
		"armor":
			player.stats.defense += 3.0

func _cast_lightning(level: int) -> void:
	var enemies = get_tree().get_nodes_in_group("enemies")
	if enemies.is_empty():
		return
	
	var strike_count = 1 + (level >> 1)
	var shuffled = enemies.duplicate()
	shuffled.shuffle()
	
	var light_scene = load("res://scenes/skills/lightning_strike.tscn")
	if not light_scene:
		return
	
	for i in range(min(strike_count, shuffled.size())):
		var target_enemy = shuffled[i]
		if is_instance_valid(target_enemy) and target_enemy.visible and not target_enemy.get("is_dead"):
			var strike = light_scene.instantiate()
			player.get_parent().add_child(strike)
			strike.strike_target(target_enemy, 35.0 + (level * 15.0))

func _cast_molotov(level: int) -> void:
	var molo_scene = load("res://scenes/skills/molotov_fire.tscn")
	if not molo_scene:
		return
	
	var molo = molo_scene.instantiate()
	var offset = Vector2(randf_range(-100, 100), randf_range(-100, 100))
	molo.global_position = player.global_position + offset
	molo.damage_per_sec = 20.0 + (level * 8.0)
	player.get_parent().add_child(molo)

func _cast_soccer(level: int) -> void:
	var soccer_scene = load("res://scenes/skills/soccer_ball.tscn")
	if not soccer_scene:
		return
	
	var ball = soccer_scene.instantiate()
	ball.global_position = player.global_position
	var rand_dir = Vector2.from_angle(randf() * TAU)
	ball.launch(rand_dir, 30.0 + (level * 12.0))
	player.get_parent().add_child(ball)

func _cast_kunai(level: int) -> void:
	var closest = player._find_closest_enemy()
	if not closest:
		return
	
	var dir = (closest.global_position - player.global_position).normalized()
	var proj = ObjectPool.spawn_projectile(player.global_position, dir, 18.0 + (level * 8.0), player.get_parent())
	if proj:
		proj.set("speed", 600.0)



func get_available_upgrade_options() -> Array[Dictionary]:
	var available: Array[Dictionary] = []
	for skill_id in SKILL_DEFS.keys():
		var def = SKILL_DEFS[skill_id]
		var cur_lv = 0
		if def.type == "weapon":
			cur_lv = active_skills.get(skill_id, 0)
		else:
			cur_lv = passive_skills.get(skill_id, 0)
		
		if cur_lv < 5:
			var opt = def.duplicate()
			opt["current_level"] = cur_lv
			opt["next_level"] = cur_lv + 1
			available.append(opt)
	
	available.shuffle()
	return available
