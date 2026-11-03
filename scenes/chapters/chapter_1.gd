extends Node2D

@export var slime_scene: PackedScene = preload("res://scenes/entities/slime_enemy.tscn")
@export var bat_scene: PackedScene = preload("res://scenes/entities/bat_enemy.tscn")
@export var lancer_scene: PackedScene = preload("res://scenes/entities/lancer_enemy.tscn")
@export var necromancer_scene: PackedScene = preload("res://scenes/entities/necromancer_boss.tscn")
@export var drop_item_scene: PackedScene = preload("res://scenes/items/drop_item.tscn")

@onready var player: Player = $Player
@onready var hp_progress_bar: ProgressBar = %HPProgressBar
@onready var hp_label: Label = %HPLabel
@onready var xp_progress_bar: ProgressBar = %XPProgressBar
@onready var level_label: Label = %LevelLabel
@onready var kill_count_label: Label = %KillCountLabel
@onready var time_label: Label = %TimeLabel
@onready var announcement_label: Label = %AnnouncementLabel
@onready var coin_hud_label: Label = %CoinHUDLabel
@onready var coin_hud_icon: TextureRect = %CoinHUDIcon
@onready var user_level_hud_label: Label = %UserLevelHUDLabel

@onready var settings_menu: PanelContainer = %SettingsMenu
@onready var skill_chest_menu: PanelContainer = %SkillChestMenu
@onready var level_up_menu: PanelContainer = %LevelUpMenu
@onready var victory_panel: PanelContainer = %VictoryPanel
@onready var victory_reward_label: Label = %VictoryRewardLabel
@onready var victory_lobby_btn: Button = %VictoryLobbyButton

@onready var slime_spawn_timer: Timer = $SlimeSpawnTimer
@onready var bat_spawn_timer: Timer = $BatSpawnTimer

@onready var boss_hud: VBoxContainer = %BossHUD
@onready var boss_name_label: Label = %BossNameLabel
@onready var boss_hp_bar: ProgressBar = %BossHPProgressBar
@onready var boss_hp_label: Label = %BossHPLabel

var elapsed_time: float = 0.0
var kill_count: int = 0
var current_level: int = 1
var current_xp: float = 0.0
var max_xp: float = 30.0

var last_2min_lancer_cycle: int = 0
var last_5min_event_cycle: int = 0
var last_announced_minute_tier: int = -1
var game_over: bool = false

# 몬스터 종류별 프리로드 텍스처 데이터
var monster_configs: Dictionary = {}

func _ready() -> void:
	if player:
		player.hp_changed.connect(_on_player_hp_changed)
		player.player_died.connect(_on_player_died)
	
	_init_monster_configs()
	
	slime_spawn_timer.timeout.connect(_on_slime_spawn_timer_timeout)
	bat_spawn_timer.timeout.connect(_on_bat_spawn_timer_timeout)
	
	settings_menu.hide()
	skill_chest_menu.hide()
	level_up_menu.hide()
	if boss_hud:
		boss_hud.hide()
	if victory_panel:
		victory_panel.hide()
	if victory_lobby_btn:
		victory_lobby_btn.pressed.connect(_on_lobby_btn_pressed)
	
	announcement_label.text = ""
	
	if coin_hud_icon:
		coin_hud_icon.texture = SettingsManager.get_coin_texture()
	
	SettingsManager.coins_changed.connect(_on_settings_coins_changed)
	_update_coin_ui()
	_update_user_level_ui()
	_update_kill_count_ui()
	_update_xp_ui()
	
	# 버프 / 디버프 실시간 표시 HUD 생성 및 플레이어 연동
	var buff_hud_script = preload("res://scenes/ui/buff_display_hud.gd")
	var buff_hud = buff_hud_script.new()
	buff_hud.name = "BuffDisplayHUD"
	var hp_container = %HPProgressBar.get_parent()
	if hp_container:
		hp_container.add_child(buff_hud)
	buff_hud.set_target_player(player)

func _init_monster_configs() -> void:
	monster_configs = {
		"skeleton": {
			"id": "skeleton",
			"name": "해골 병사",
			"texture": load("res://assets/ch1/Characters(100x100 split)/Skeleton/Skeleton/Skeleton_Walk.png"),
			"hframes": 8,
			"hp": 24.0,
			"speed": 85.0,
			"damage": 3.0,
			"defense": 1.0,
			"scale": Vector2(1.8, 1.8),
			"impact_color": "yellow",
			"hit_debuff": "debuff_weakness"
		},
		"armored_skeleton": {
			"id": "armored_skeleton",
			"name": "무장 해골",
			"texture": load("res://assets/ch1/Characters(100x100 split)/Armored Skeleton/Armored Skeleton/Armored Skeleton_Walk.png"),
			"hframes": 8,
			"hp": 55.0,
			"speed": 75.0,
			"damage": 5.0,
			"defense": 4.0,
			"scale": Vector2(2.0, 2.0),
			"impact_color": "yellow",
			"buff_to_self": "buff_stone_skin",
			"buff_interval": 8.0,
			"hit_debuff": "debuff_armor_break"
		},
		"orc": {
			"id": "orc",
			"name": "오크 전사",
			"texture": load("res://assets/ch1/Characters(100x100 split)/Orc/Orc/Orc_Walk.png"),
			"hframes": 8,
			"hp": 90.0,
			"speed": 80.0,
			"damage": 7.0,
			"defense": 6.0,
			"scale": Vector2(2.2, 2.2),
			"impact_color": "orange",
			"buff_to_self": "buff_might",
			"buff_interval": 7.0,
			"hit_debuff": "debuff_cripple"
		},
		"elite_orc": {
			"id": "elite_orc",
			"name": "엘리트 오크",
			"texture": load("res://assets/ch1/Characters(100x100 split)/Elite Orc/Elite Orc/Elite Orc_Walk.png"),
			"hframes": 8,
			"hp": 160.0,
			"speed": 90.0,
			"damage": 10.0,
			"defense": 8.0,
			"scale": Vector2(2.4, 2.4),
			"impact_color": "orange",
			"buff_to_self": "buff_berserk",
			"buff_interval": 6.0,
			"hit_debuff": "debuff_fracture"
		},
		"werewolf": {
			"id": "werewolf",
			"name": "웨어울프",
			"texture": load("res://assets/ch1/Characters(100x100 split)/Werewolf/Werewolf/Werewolf_Walk.png"),
			"hframes": 8,
			"hp": 230.0,
			"speed": 130.0,
			"damage": 13.0,
			"defense": 10.0,
			"scale": Vector2(2.2, 2.2),
			"impact_color": "red",
			"buff_to_self": "buff_haste",
			"buff_interval": 5.0,
			"hit_debuff": "debuff_bleed"
		},
		"hellbat": {
			"id": "hellbat",
			"name": "헬뱃",
			"texture": load("res://assets/ch2/Characters(100x100 split)/Hellbat/Hellbat/Hellbat_Flying.png"),
			"hframes": 6,
			"hp": 110.0,
			"speed": 165.0,
			"damage": 12.0,
			"defense": 6.0,
			"scale": Vector2(2.0, 2.0),
			"impact_color": "violet",
			"aura_debuff": "debuff_curse",
			"hit_debuff": "debuff_confusion"
		},
		"hellhound": {
			"id": "hellhound",
			"name": "지옥견",
			"texture": load("res://assets/ch2/Characters(100x100 split)/Hellhound/Hellhound/Hellhound_Walk.png"),
			"hframes": 8,
			"hp": 360.0,
			"speed": 140.0,
			"damage": 17.0,
			"defense": 12.0,
			"scale": Vector2(2.3, 2.3),
			"impact_color": "red",
			"buff_to_self": "buff_dash_surge",
			"buff_interval": 6.0,
			"hit_debuff": "debuff_burn"
		},
		"ghostfire": {
			"id": "ghostfire",
			"name": "유령 불꽃",
			"texture": load("res://assets/ch2/Characters(100x100 split)/Ghostfire/Ghostfire/Ghostfire_Flying.png"),
			"hframes": 6,
			"hp": 480.0,
			"speed": 105.0,
			"damage": 22.0,
			"defense": 15.0,
			"scale": Vector2(2.4, 2.4),
			"impact_color": "blue",
			"aura_debuff": "debuff_chill",
			"hit_debuff": "debuff_frostbite"
		},
		"demon_a": {
			"id": "demon_a",
			"name": "하급 악마",
			"texture": load("res://assets/ch2/Characters(100x100 split)/Demon_A/Demon_A/Demon_A_Walk.png"),
			"hframes": 8,
			"hp": 750.0,
			"speed": 100.0,
			"damage": 28.0,
			"defense": 20.0,
			"scale": Vector2(2.5, 2.5),
			"impact_color": "violet",
			"buff_to_self": "buff_demonic_rage",
			"buff_interval": 8.0,
			"hit_debuff": "debuff_hellfire"
		},
		"minotaur": {
			"id": "minotaur",
			"name": "미노타우로스",
			"texture": load("res://assets/ch2/Characters(100x100 split)/Minotaur/Minotaur/Minotaur_Walk.png"),
			"hframes": 8,
			"hp": 1300.0,
			"speed": 95.0,
			"damage": 38.0,
			"defense": 30.0,
			"scale": Vector2(2.8, 2.8),
			"impact_color": "orange",
			"buff_to_self": "buff_giant_strength",
			"buff_interval": 9.0,
			"hit_debuff": "debuff_exhaustion"
		},
		"flame_golem": {
			"id": "flame_golem",
			"name": "화염 골렘",
			"texture": load("res://assets/ch2/Characters(100x100 split)/Flame Golem/Flame Golem/Flame Golem_Walk.png"),
			"hframes": 12,
			"hp": 2400.0,
			"speed": 85.0,
			"damage": 50.0,
			"defense": 45.0,
			"scale": Vector2(3.0, 3.0),
			"impact_color": "red",
			"buff_to_self": "buff_flame_shield",
			"buff_interval": 10.0,
			"aura_debuff": "debuff_burn",
			"hit_debuff": "debuff_lava_burn"
		},
		"black_knight": {
			"id": "black_knight",
			"name": "심연의 흑기사",
			"texture": load("res://assets/ch2/Characters(100x100 split)/Black Knight_A/Black Knight_A/Black Knight_A_Walk.png"),
			"hframes": 8,
			"hp": 4500.0,
			"speed": 115.0,
			"damage": 70.0,
			"defense": 60.0,
			"scale": Vector2(3.0, 3.0),
			"impact_color": "violet",
			"buff_to_self": "buff_abyssal_might",
			"buff_interval": 7.0,
			"aura_debuff": "debuff_terror",
			"hit_debuff": "debuff_doom"
		}
	}

func _on_settings_coins_changed(_amount: float) -> void:
	_update_coin_ui()

func _update_coin_ui() -> void:
	if coin_hud_label:
		coin_hud_label.text = "%s" % SettingsManager.format_unit(SettingsManager.coins)

func _update_user_level_ui() -> void:
	if user_level_hud_label:
		user_level_hud_label.text = "🎖️ 유저 Lv. %d" % SettingsManager.user_level

func _process(delta: float) -> void:
	if game_over:
		return
		
	elapsed_time += delta
	var total_sec: int = floori(elapsed_time)
	var minutes: int = int(total_sec / 60.0)
	var seconds: int = total_sec % 60
	time_label.text = "%02d:%02d" % [minutes, seconds]
	
	_check_events(total_sec)
	
	if Input.is_action_just_pressed("ui_cancel"):
		_toggle_settings()

func _check_events(total_sec: int) -> void:
	var minutes = int(total_sec / 60.0)
	
	# 분 단위 티어 전환 안내 배너
	if minutes != last_announced_minute_tier:
		last_announced_minute_tier = minutes
		_announce_tier_transition(minutes)
	
	# 1) 2분마다 Lancer 및 중간보스 급습 (무한 주기)
	var current_2min: int = int(total_sec / 120.0)
	if current_2min > 0 and current_2min > last_2min_lancer_cycle:
		last_2min_lancer_cycle = current_2min
		_spawn_miniboss_cycle(current_2min)
	
	# 2) 5분마다 대량 발생 이벤트 및 엘리트 군단 습격
	var current_5min: int = int(total_sec / 300.0)
	if current_5min > 0 and current_5min > last_5min_event_cycle:
		last_5min_event_cycle = current_5min
		_trigger_swarm_event(current_5min)

func _announce_tier_transition(mins: int) -> void:
	match mins:
		1:
			show_banner("⏱️ 1분 돌파: 스켈레톤 군단이 합류합니다!", Color(0.8, 0.9, 1.0))
		2:
			show_banner("⏱️ 2분 돌파: 중무장 병력이 전선에 투입됩니다!", Color(1.0, 0.8, 0.3))
		3:
			show_banner("⏱️ 3분 돌파: 오크 전사 부대가 진격해옵니다!", Color(0.9, 0.6, 0.2))
		5:
			show_banner("⏱️ 5분 돌파: 야수와 엘리트 병력이 밀려옵니다!", Color(1.0, 0.4, 0.2))
		7:
			show_banner("⏱️ 7분 돌파: 지옥의 문이 열렸습니다! 지옥 생물 출현!", Color(1.0, 0.25, 0.25))
		10:
			show_banner("⏱️ 10분 돌파: 악마 군단과 유령 불꽃이 포위합니다!", Color(0.9, 0.2, 0.9))
		15:
			show_banner("🔥 15분 한계 돌파! 네크로맨서와 무한 심연의 군단 출현! 🔥", Color(1.0, 0.1, 0.1))
		20:
			show_banner("⚡ 20분 극한 생존! 화염 골렘과 심연 흑기사가 전장을 뒤덮습니다! ⚡", Color(1.0, 0.3, 0.0))

func _spawn_miniboss_cycle(cycle: int) -> void:
	if not player or not is_instance_valid(player) or player.is_dead or game_over:
		return
	
	# 주기에 따라 강화된 랜서 또는 보스 출현 (7 또는 8주기(약 15분)마다 보스 출현)
	if cycle % 7 == 0:
		_spawn_necromancer_boss()
	elif lancer_scene:
		var lancer = lancer_scene.instantiate()
		lancer.global_position = _get_spawn_position(500.0, 650.0)
		# 시간 경과에 비례해 체력/공격력 비례 강화
		var scale_factor = 1.0 + (cycle * 0.25)
		if "max_hp" in lancer:
			lancer.max_hp *= scale_factor
			lancer.current_hp = lancer.max_hp
		if "attack_damage" in lancer:
			lancer.attack_damage *= scale_factor
		add_child(lancer)
		show_banner("⚠ 중간 보스 [강화 랜서 (Tier %d)] 급습! ⚠" % cycle, Color(1.0, 0.7, 0.2))

func _trigger_swarm_event(cycle: int) -> void:
	show_banner("🚨 %d분 주기: 대량 몬스터 무리 습격 발생! 🚨" % (cycle * 5), Color(1.0, 0.4, 0.2))
	var count = 15 + cycle * 3
	for i in range(count):
		_spawn_timed_monster()

func _spawn_slime() -> void:
	if not player or not is_instance_valid(player) or player.is_dead or game_over:
		return
	var spawn_pos = _get_spawn_position(450.0, 600.0)
	ObjectPool.spawn_slime(spawn_pos, 1, self)

func _spawn_bat() -> void:
	if not player or not is_instance_valid(player) or player.is_dead or game_over:
		return
	var spawn_pos = _get_spawn_position(450.0, 620.0)
	ObjectPool.spawn_bat(spawn_pos, self)

func _spawn_bat_pack() -> void:
	if not player or not is_instance_valid(player) or player.is_dead or game_over:
		return
	var pack_size = randi_range(4, 6)
	var base_pos = _get_spawn_position(500.0, 650.0)
	for i in range(pack_size):
		var spawn_pos = base_pos + Vector2(randf_range(-30, 30), randf_range(-30, 30))
		ObjectPool.spawn_bat(spawn_pos, self)

func _spawn_timed_monster() -> void:
	if not player or not is_instance_valid(player) or player.is_dead or game_over:
		return
	
	var mins = elapsed_time / 60.0
	var pool_list: Array[String] = []
	
	if mins < 1.0:
		# 0~1분: 슬라임 위주
		_spawn_slime()
		return
	elif mins < 2.0:
		# 1~2분: 슬라임, 박쥐, 스켈레톤
		pool_list = ["slime", "bat", "skeleton", "skeleton"]
	elif mins < 3.0:
		# 2~3분: 스켈레톤, 무장 해골
		pool_list = ["skeleton", "armored_skeleton", "armored_skeleton", "bat"]
	elif mins < 5.0:
		# 3~5분: 무장 해골, 오크
		pool_list = ["armored_skeleton", "orc", "orc", "skeleton"]
	elif mins < 7.0:
		# 5~7분: 오크, 엘리트 오크, 웨어울프
		pool_list = ["orc", "elite_orc", "werewolf", "werewolf"]
	elif mins < 10.0:
		# 7~10분: 헬뱃, 지옥견, 유령 불꽃
		pool_list = ["hellbat", "hellhound", "ghostfire", "werewolf"]
	elif mins < 15.0:
		# 10~15분: 지옥견, 유령 불꽃, 하급 악마, 미노타우로스
		pool_list = ["hellhound", "ghostfire", "demon_a", "minotaur"]
	elif mins < 20.0:
		# 15~20분: 악마 군단, 화염 골렘, 미노타우로스
		pool_list = ["demon_a", "minotaur", "flame_golem", "black_knight"]
	else:
		# 20분 이후 (무한 심연): 최강 몬스터 풀
		pool_list = ["black_knight", "flame_golem", "minotaur", "demon_a", "hellhound"]
	
	var chosen = pool_list.pick_random()
	if chosen == "slime":
		_spawn_slime()
	elif chosen == "bat":
		_spawn_bat()
	else:
		_spawn_generic_by_id(chosen)

func _spawn_generic_by_id(m_id: String) -> void:
	if not monster_configs.has(m_id):
		return
	var base_cfg = monster_configs[m_id].duplicate()
	
	# 15분 이후 무한 생존 모드에서 몬스터 스탯 지속 증가
	var mins = elapsed_time / 60.0
	if mins > 15.0:
		var extra_tier = (mins - 15.0) * 0.12 # 매 분마다 12% 강화
		base_cfg["hp"] = base_cfg["hp"] * (1.0 + extra_tier)
		base_cfg["damage"] = base_cfg["damage"] * (1.0 + extra_tier)
	
	var spawn_pos = _get_spawn_position(480.0, 650.0)
	ObjectPool.spawn_generic_enemy(base_cfg, spawn_pos, self)

func _spawn_necromancer_boss() -> void:
	if not player or not is_instance_valid(player) or player.is_dead or game_over:
		return
	if necromancer_scene:
		var boss = necromancer_scene.instantiate()
		boss.global_position = _get_spawn_position(550.0, 700.0)
		add_child(boss)
		show_banner("☠ 보스 [네크로맨서] 등장! 무한 생존 전투! ☠", Color(1.0, 0.2, 0.2))
		
		# Boss HUD 설정 및 표시
		if boss_hud and boss_hp_bar:
			boss_hp_bar.max_value = boss.max_hp
			boss_hp_bar.value = boss.current_hp
			if boss_name_label:
				boss_name_label.text = "☠ 보스: 네크로맨서 ☠"
			if boss_hp_label:
				boss_hp_label.text = "%s / %s" % [SettingsManager.format_unit(boss.current_hp), SettingsManager.format_unit(boss.max_hp)]
			boss_hud.show()
			
			boss.hp_changed.connect(_on_boss_hp_changed)
			boss.boss_died.connect(_on_boss_died)
			if boss.has_signal("buff_applied"):
				boss.buff_applied.connect(_on_boss_buff_applied)

func _on_boss_buff_applied(stacks: int, multiplier: float) -> void:
	if boss_name_label:
		var pct_bonus = int(round((multiplier - 1.0) * 100.0))
		boss_name_label.text = "☠ 보스: 네크로맨서 [분노 +%d%%] (%d분 버팀) ☠" % [pct_bonus, stacks]
	show_banner("⚡ 보스 강화! 1분 경과로 전체 능력치 +%d%% 상승! ⚡" % stacks, Color(1.0, 0.35, 0.1))

func _on_boss_hp_changed(current: float, maximum: float) -> void:
	if boss_hp_bar:
		boss_hp_bar.max_value = maximum
		boss_hp_bar.value = current
	if boss_hp_label:
		boss_hp_label.text = "%s / %s" % [SettingsManager.format_unit(current), SettingsManager.format_unit(maximum)]

func _on_boss_died() -> void:
	if boss_hud:
		boss_hud.hide()
	show_banner("🏆 보스 네크로맨서 격파! 대량의 전리품 획득! 🏆", Color(1.0, 0.85, 0.2))
	# 보스를 쓰러뜨려도 게임이 강제 종료되지 않고 무한 생존 지속!
	var result = SettingsManager.complete_chapter(1)
	if result:
		show_banner("🎖️ 보스 처치 특별 보너스! 레벨 +%d, 골드 획득! 🎖️" % result["gained_level"], Color(0.4, 1.0, 0.4))

func spawn_boss_rewards(pos: Vector2) -> void:
	# Boss loot: Chest, Magnet, Meat, Gold Bags, Gems, and Character Shards + Clear Item
	var loot_items: Array[DropItem.ItemType] = [
		DropItem.ItemType.CHEST,
		DropItem.ItemType.MAGNET,
		DropItem.ItemType.FOOD,
		DropItem.ItemType.GOLD_BAG,
		DropItem.ItemType.XP_GEM_GOLD,
		DropItem.ItemType.SHARD_SKELETON,
		DropItem.ItemType.SHARD_SOLDIER,
		DropItem.ItemType.SHARD_KNIGHT,
		DropItem.ItemType.CLEAR_ITEM
	]
	
	var angle_step = TAU / loot_items.size()
	for i in range(loot_items.size()):
		var offset = Vector2.from_angle(i * angle_step) * 40.0
		ObjectPool.spawn_drop_item(loot_items[i], pos + offset, self)

func trigger_magnet_effect(player_node: Node2D) -> void:
	var items = get_tree().get_nodes_in_group("drop_items")
	for item in items:
		if is_instance_valid(item) and item.has_method("attract_to") and item.visible:
			item.attract_to(player_node)

func trigger_bomb_effect() -> void:
	show_banner("💣 폭탄 발동! 화면 내 모든 적 처치! 💥", Color(1.0, 0.35, 0.2))
	var enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		if is_instance_valid(enemy) and enemy.has_method("take_damage") and not enemy.get("is_dead") and enemy.visible:
			enemy.take_damage(9999.0)

func open_skill_chest() -> void:
	if skill_chest_menu:
		var random_skill_count = randi_range(3, 5)
		skill_chest_menu.open_chest(random_skill_count)

func add_xp(amount: float) -> void:
	current_xp += amount
	SettingsManager.coins += int(amount)
	
	while current_xp >= max_xp:
		current_xp -= max_xp
		current_level += 1
		max_xp = int(30.0 * pow(1.25, current_level - 1))
		_trigger_level_up()
		
	_update_xp_ui()

func _trigger_level_up() -> void:
	show_banner("⭐ LEVEL UP! (Lv. %d) ⭐" % current_level, Color(1.0, 0.9, 0.2))
	if level_up_menu and player:
		var options: Array[Dictionary] = []
		if player.has_method("get_skill_options"):
			options = player.get_skill_options()
		if not options.is_empty():
			level_up_menu.open_level_up(options)

func _update_xp_ui() -> void:
	if xp_progress_bar:
		xp_progress_bar.max_value = max_xp
		xp_progress_bar.value = current_xp
	if level_label:
		level_label.text = "Lv. %d" % current_level

func on_enemy_killed(enemy_type: String, pos: Vector2) -> void:
	kill_count += 1
	_update_kill_count_ui()
	
	# Normal enemies drop roll (45% chance)
	if randf() < 0.45:
		var chosen_type: DropItem.ItemType = DropItem.ItemType.XP_GEM_GREEN
		var roll = randf()
		if roll < 0.40:
			chosen_type = DropItem.ItemType.XP_GEM_GREEN
		elif roll < 0.65:
			chosen_type = DropItem.ItemType.XP_GEM_BLUE
		elif roll < 0.80:
			chosen_type = DropItem.ItemType.GOLD_COIN
		elif roll < 0.92:
			# 특공대 조각 드랍 (스켈레톤, 솔저, 기사)
			var shard_roll = randf()
			if shard_roll < 0.45:
				chosen_type = DropItem.ItemType.SHARD_SKELETON
			elif shard_roll < 0.75:
				chosen_type = DropItem.ItemType.SHARD_SOLDIER
			else:
				chosen_type = DropItem.ItemType.SHARD_KNIGHT
		elif roll < 0.97:
			chosen_type = DropItem.ItemType.FOOD
		else:
			chosen_type = DropItem.ItemType.BOMB
		
		ObjectPool.spawn_drop_item(chosen_type, pos, self)

func _update_kill_count_ui() -> void:
	if kill_count_label:
		kill_count_label.text = "💀 처치: %s" % SettingsManager.format_unit(kill_count)

func _get_spawn_position(min_dist: float, max_dist: float) -> Vector2:
	var angle = randf() * TAU
	var dist = randf_range(min_dist, max_dist)
	return player.global_position + Vector2.from_angle(angle) * dist

func show_banner(text: String, col: Color) -> void:
	announcement_label.text = text
	announcement_label.modulate = col
	var tween = create_tween()
	tween.tween_property(announcement_label, "modulate:a", 1.0, 0.3)
	tween.tween_interval(2.5)
	tween.tween_property(announcement_label, "modulate:a", 0.0, 0.6)

func _on_slime_spawn_timer_timeout() -> void:
	_spawn_timed_monster()

func _on_bat_spawn_timer_timeout() -> void:
	var mins = elapsed_time / 60.0
	if mins < 3.0:
		_spawn_bat_pack()
	elif mins < 8.0:
		_spawn_timed_monster()
		_spawn_timed_monster()
	else:
		# 고난도 무한 모드: 빠른 주기 3마리씩 출현
		for i in range(3):
			_spawn_timed_monster()

func _on_player_hp_changed(current: float, maximum: float) -> void:
	hp_progress_bar.max_value = maximum
	hp_progress_bar.value = current
	if hp_label:
		hp_label.text = "HP: %s / %s" % [SettingsManager.format_unit(max(0, current)), SettingsManager.format_unit(maximum)]

func _on_player_died() -> void:
	if game_over:
		return
	game_over = true
	slime_spawn_timer.stop()
	bat_spawn_timer.stop()
	time_label.text += " (GAME OVER)"
	show_banner("💀 작전 실패 (YOU DIED) 💀", Color.RED)
	
	if boss_hud:
		boss_hud.hide()
	
	# 작전 실패/결과 패널 표시 (생존 시간 및 기록 제공)
	if victory_panel:
		var title_label = victory_panel.find_child("Title", true, false)
		if title_label:
			title_label.text = "💀 전투 종료 (GAME OVER) 💀"
			title_label.modulate = Color(1.0, 0.3, 0.3)
		if victory_reward_label:
			var total_sec: int = floori(elapsed_time)
			var minutes: int = int(total_sec / 60.0)
			var seconds: int = total_sec % 60
			victory_reward_label.text = """[ 생존 전투 기록 ]
• ⏱️ 생존 시간: %02d분 %02d초
• 🪙 획득 골드: %s 코인
• 💀 총 처치 수: %s 마리
• ⭐ 최종 레벨: Lv. %d""" % [
				minutes,
				seconds,
				SettingsManager.format_unit(SettingsManager.coins),
				SettingsManager.format_unit(kill_count),
				current_level
			]
		victory_panel.show()

func _toggle_settings() -> void:
	settings_menu.visible = not settings_menu.visible

func _on_settings_btn_pressed() -> void:
	_toggle_settings()

func _on_lobby_btn_pressed() -> void:
	get_tree().paused = false
	ObjectPool.clear_all()
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
