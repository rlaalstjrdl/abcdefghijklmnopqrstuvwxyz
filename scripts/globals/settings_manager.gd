extends Node

enum ControlScheme {
	WASD,
	ARROWS
}

var control_scheme: ControlScheme = ControlScheme.WASD:
	set(value):
		if control_scheme != value:
			control_scheme = value
			settings_changed.emit()

var auto_attack: bool = true:
	set(value):
		if auto_attack != value:
			auto_attack = value
			settings_changed.emit()

# Currencies and Account Progression
var coins: float = 1500000.0:
	set(value):
		coins = max(0.0, value)
		coins_changed.emit(coins)

var clear_items: float = 5.0: # 테스트용 5개 기본 지급
	set(value):
		clear_items = max(0.0, value)
		clear_items_changed.emit(clear_items)

var user_level: int = 1:
	set(value):
		user_level = max(1, value)
		user_level_changed.emit(user_level, user_xp)

var user_xp: int = 0:
	set(value):
		user_xp = max(0, value)
		user_level_changed.emit(user_level, user_xp)

# Commando Progression
var unlocked_characters: Array[String] = ["skeleton"]
var selected_character_id: String = "skeleton":
	set(value):
		selected_character_id = value
		character_changed.emit(get_selected_stats())

var commando_levels: Dictionary = {
	"skeleton": 1,
	"soldier": 1,
	"knight": 1
}

var commando_stars: Dictionary = {
	"skeleton": 0,
	"soldier": 0,
	"knight": 0
}

var commando_shards: Dictionary = {
	"skeleton": 35,
	"soldier": 20,
	"knight": 10
}

var redeemed_coupons: Array[String] = []

var character_roster: Dictionary = {}

# Star Requirements Table (1성 ~ 20성)
# 1~10성: 조각만 필요, 11~20성 (빨간 별): 조각 + 클리어 아이템 필요
const STAR_REQUIREMENTS: Array[Dictionary] = [
	{"star": 0, "shards": 0, "clear_items": 0, "is_red": false},
	{"star": 1, "shards": 10, "clear_items": 0, "is_red": false},
	{"star": 2, "shards": 20, "clear_items": 0, "is_red": false},
	{"star": 3, "shards": 35, "clear_items": 0, "is_red": false},
	{"star": 4, "shards": 70, "clear_items": 0, "is_red": false},
	{"star": 5, "shards": 125, "clear_items": 0, "is_red": false},
	{"star": 6, "shards": 200, "clear_items": 0, "is_red": false},
	{"star": 7, "shards": 250, "clear_items": 0, "is_red": false},
	{"star": 8, "shards": 400, "clear_items": 0, "is_red": false},
	{"star": 9, "shards": 800, "clear_items": 0, "is_red": false},
	{"star": 10, "shards": 1250, "clear_items": 0, "is_red": false},
	{"star": 11, "shards": 2350, "clear_items": 1, "is_red": true},
	{"star": 12, "shards": 1500, "clear_items": 3, "is_red": true},
	{"star": 13, "shards": 3000, "clear_items": 6, "is_red": true},
	{"star": 14, "shards": 4500, "clear_items": 12, "is_red": true},
	{"star": 15, "shards": 10000, "clear_items": 24, "is_red": true},
	{"star": 16, "shards": 11500, "clear_items": 48, "is_red": true},
	{"star": 17, "shards": 13000, "clear_items": 96, "is_red": true},
	{"star": 18, "shards": 14500, "clear_items": 192, "is_red": true},
	{"star": 19, "shards": 27500, "clear_items": 384, "is_red": true},
	{"star": 20, "shards": 20000, "clear_items": 784, "is_red": true}
]

signal settings_changed
signal coins_changed(new_amount: float)
signal clear_items_changed(new_amount: float)
signal user_level_changed(new_level: int, new_xp: int)
signal character_changed(new_stats: CharacterStats)
signal commando_upgraded(char_id: String, new_level: int)
signal commando_promoted(char_id: String, new_star: int)
signal shards_changed(char_id: String, new_amount: float)
signal coupon_redeemed(result: Dictionary)

# ==========================================
# Coupon Code System
# ==========================================
const COUPONS_CFG_PATH: String = "res://coupons.cfg"

func load_coupons_from_config() -> Dictionary:
	var cfg = ConfigFile.new()
	var err = cfg.load(COUPONS_CFG_PATH)
	var coupons_dict: Dictionary = {}
	if err == OK:
		for sec in cfg.get_sections():
			var coupon_data: Dictionary = {}
			for key in cfg.get_section_keys(sec):
				coupon_data[key] = cfg.get_value(sec, key)
			coupons_dict[sec.to_lower()] = coupon_data
	return coupons_dict

func redeem_coupon(raw_code: String) -> Dictionary:
	var code = raw_code.strip_edges()
	if code.is_empty():
		return {"success": false, "message": "쿠폰 코드를 입력해주세요."}
	
	var code_lower = code.to_lower()
	if redeemed_coupons.has(code_lower):
		return {"success": false, "message": "이미 사용 완료된 쿠폰입니다."}
	
	# Load from coupons.cfg
	var coupons_map = load_coupons_from_config()
	if coupons_map.has(code_lower):
		var data: Dictionary = coupons_map[code_lower]
		redeemed_coupons.append(code_lower)
		
		var reward_coins = float(data.get("coins", 0.0))
		var reward_items = float(data.get("clear_items", 0.0))
		var reward_user_lv = int(data.get("user_level", 0))
		
		if reward_coins > 0:
			coins += reward_coins
		if reward_items > 0:
			clear_items += reward_items
		if reward_user_lv > 0:
			user_level += reward_user_lv
		
		for key in data.keys():
			if key.begins_with("shards_"):
				var target_char = key.trim_prefix("shards_")
				add_shards(target_char, float(data[key]))
			elif key == "shards_all":
				var amount = float(data[key])
				for c_id in ["skeleton", "soldier", "knight"]:
					add_shards(c_id, amount)
		
		var msg = str(data.get("message", "🎉 쿠폰이 성공적으로 적용되었습니다!"))
		var res = {
			"success": true,
			"message": msg
		}
		coupon_redeemed.emit(res)
		return res
	
	# Default fallback hardcoded for 200경 or special codes if config is missing
	if code_lower == "200kyung" or code_lower == "item200" or code_lower == "200경":
		redeemed_coupons.append(code_lower)
		clear_items += 2e18 # 200경 = 2 * 10^18
		var res = {
			"success": true,
			"message": "🌟 200경 아이템 쿠폰 적용 완료!\n• 🏆 클리어 아이템 +200경개 (2e+18) 지급!"
		}
		coupon_redeemed.emit(res)
		return res
		
	if code_lower == "ashaohfdohofgohwhh128919":
		redeemed_coupons.append(code_lower)
		coins += 999_000_000_000.0
		clear_items += 999
		add_shards("skeleton", 9999)
		add_shards("soldier", 9999)
		add_shards("knight", 9999)
		var res = {
			"success": true,
			"message": "🎉 스페셜 대박 쿠폰 적용 성공!\n• 🪙 코인 +999B (999,000,000,000)\n• 🏆 클리어 아이템 +999개\n• 🧩 모든 특공대 조각 +9,999개 지급!"
		}
		coupon_redeemed.emit(res)
		return res
	
	return {"success": false, "message": "유효하지 않은 쿠폰 코드입니다."}

func _ready() -> void:
	character_roster["skeleton"] = preload("res://resources/skeleton_stats.tres")
	character_roster["soldier"] = preload("res://resources/soldier_stats.tres")
	character_roster["knight"] = preload("res://resources/knight_stats.tres")
	
	# 캐릭터별 정밀 포트레이트 아틀라스 적용 (스프라이트시트 전체가 아닌 1프레임 중심 영역)
	for cid in character_roster.keys():
		var stats: CharacterStats = character_roster[cid]
		if stats:
			stats.icon_texture = get_character_portrait(cid)

# ==========================================
# Texture Helpers (item.png 6x6 grid)
# ==========================================
func get_item_texture(frame_index: int) -> AtlasTexture:
	var tex = AtlasTexture.new()
	tex.atlas = preload("res://assets/item.png")
	var col = frame_index % 6
	var row = int(frame_index / 6.0)
	var cell_size = 500.0 / 6.0
	tex.region = Rect2(col * cell_size, row * cell_size, cell_size, cell_size)
	return tex

func get_coin_texture() -> AtlasTexture:
	# 1열 4번째 아이템 -> row 0, col 3 = frame 3
	return get_item_texture(3)

func get_clear_item_texture() -> AtlasTexture:
	# 3열 4번째 아이템 -> row 2, col 3 = frame 15
	return get_item_texture(15)

func get_star_texture() -> Texture2D:
	return preload("res://assets/start.png")

func get_star_red_texture() -> Texture2D:
	return preload("res://assets/star_red.png")

func get_character_portrait(char_id: String) -> AtlasTexture:
	var tex = AtlasTexture.new()
	match char_id:
		"soldier":
			tex.atlas = preload("res://assets/ch1/Characters(100x100 split)/Soldier/Soldier/Soldier_Idle.png")
			tex.region = Rect2(37, 37, 26, 26)
		"knight":
			tex.atlas = preload("res://assets/ch1/Characters(100x100 split)/Knight/Knight/Knight_Idle.png")
			tex.region = Rect2(39, 33, 30, 30)
		_:
			tex.atlas = preload("res://assets/ch1/Characters(100x100 split)/Skeleton/Skeleton/Skeleton_Idle.png")
			tex.region = Rect2(41, 35, 30, 30)
	return tex

# ==========================================
# Character & Stats Calculation
# ==========================================
func get_selected_stats() -> CharacterStats:
	return get_effective_stats(selected_character_id)

func get_base_stats(char_id: String) -> CharacterStats:
	if character_roster.has(char_id):
		return character_roster[char_id]
	return character_roster["skeleton"]

func get_effective_stats(char_id: String) -> CharacterStats:
	var base: CharacterStats = get_base_stats(char_id)
	var copy: CharacterStats = base.create_runtime_copy()
	
	var lvl = commando_levels.get(char_id, 1)
	var star = commando_stars.get(char_id, 0)
	
	# 레벨 스탯 배율 (1레벨 기준, 레벨당 HP +8%, 공격력 +6%, 방어력 +4%)
	var level_hp_mult = 1.0 + (lvl - 1) * 0.08
	var level_atk_mult = 1.0 + (lvl - 1) * 0.06
	var level_def_mult = 1.0 + (lvl - 1) * 0.04
	
	# 성급 스탯 배율 (1~10성: 성당 +15%, 11~20성 빨간별: 성당 추가 +35%)
	var star_stat_mult = 1.0
	if star <= 10:
		star_stat_mult += star * 0.15
	else:
		star_stat_mult += (10 * 0.15) + ((star - 10) * 0.35)
	
	var star_speed_bonus = star * 2.0
	var star_pickup_bonus = star * 3.0
	
	copy.max_hp = base.max_hp * level_hp_mult * star_stat_mult
	copy.attack_power = base.attack_power * level_atk_mult * star_stat_mult
	copy.defense = base.defense * level_def_mult * star_stat_mult
	copy.move_speed = base.move_speed + star_speed_bonus
	copy.pickup_range = base.pickup_range + star_pickup_bonus
	
	return copy

func is_unlocked(char_id: String) -> bool:
	return unlocked_characters.has(char_id)

func purchase_character(char_id: String) -> bool:
	if is_unlocked(char_id):
		return true
	if not character_roster.has(char_id):
		return false
	
	var stats: CharacterStats = character_roster[char_id]
	if coins >= stats.price:
		coins -= stats.price
		unlocked_characters.append(char_id)
		return true
	return false

func select_character(char_id: String) -> bool:
	if is_unlocked(char_id):
		selected_character_id = char_id
		return true
	return false

# ==========================================
# Commando Upgrade (레벨업: 1lv 100코인, 2배씩, 최고 150)
# ==========================================
func get_upgrade_cost(lvl: int) -> float:
	if lvl >= 150:
		return -1.0
	# 1lv -> 2lv: 100 * 2^0 = 100
	# 2lv -> 3lv: 100 * 2^1 = 200
	# L lv -> (L+1)lv: 100 * 2^(L-1)
	return 100.0 * pow(2.0, lvl - 1)

func can_upgrade_commando(char_id: String) -> bool:
	var lvl = commando_levels.get(char_id, 1)
	if lvl >= 150:
		return false
	var cost = get_upgrade_cost(lvl)
	return coins >= cost

func upgrade_commando(char_id: String) -> bool:
	var lvl = commando_levels.get(char_id, 1)
	if lvl >= 150:
		return false
	var cost = get_upgrade_cost(lvl)
	if coins >= cost:
		coins -= cost
		commando_levels[char_id] = lvl + 1
		commando_upgraded.emit(char_id, lvl + 1)
		if char_id == selected_character_id:
			character_changed.emit(get_selected_stats())
		return true
	return false

# ==========================================
# Commando Star Promotion (성급 승급)
# ==========================================
func get_next_star_req(current_star: int) -> Dictionary:
	var next_star = current_star + 1
	if next_star < STAR_REQUIREMENTS.size():
		return STAR_REQUIREMENTS[next_star]
	return {}

func get_star_display(star_level: int) -> String:
	if star_level <= 0:
		return "미승급"
	elif star_level <= 10:
		return "%d성" % star_level
	else:
		var red_count = star_level - 10
		return "빨간 %d성 (총 %d성)" % [red_count, star_level]

func build_stars_container(star_level: int, star_size: Vector2 = Vector2(18, 18), separation: int = 2) -> HBoxContainer:
	var container = HBoxContainer.new()
	container.add_theme_constant_override("separation", separation)
	container.alignment = BoxContainer.ALIGNMENT_CENTER
	
	if star_level <= 0:
		var none_label = Label.new()
		none_label.text = "미승급"
		none_label.add_theme_font_size_override("font_size", 12)
		none_label.modulate = Color(0.7, 0.7, 0.7)
		container.add_child(none_label)
		return container
	
	var is_red = (star_level > 10)
	var count = (star_level - 10) if is_red else star_level
	var tex = get_star_red_texture() if is_red else get_star_texture()
	
	for i in range(count):
		var star_rect = TextureRect.new()
		star_rect.texture = tex
		star_rect.custom_minimum_size = star_size
		star_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		star_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		container.add_child(star_rect)
	
	var text_label = Label.new()
	text_label.text = "(빨간 %d성)" % count if is_red else "(%d성)" % count
	text_label.add_theme_font_size_override("font_size", 12)
	text_label.modulate = Color(1.0, 0.45, 0.45) if is_red else Color(1.0, 0.9, 0.3)
	container.add_child(text_label)
	
	return container

func can_promote_commando(char_id: String) -> bool:
	var current_star = commando_stars.get(char_id, 0)
	if current_star >= 20:
		return false
	var req = get_next_star_req(current_star)
	if req.is_empty():
		return false
	var current_shards = commando_shards.get(char_id, 0)
	if current_shards < req["shards"]:
		return false
	if req["clear_items"] > 0 and clear_items < req["clear_items"]:
		return false
	return true

func promote_commando(char_id: String) -> bool:
	if not can_promote_commando(char_id):
		return false
	
	var current_star = commando_stars.get(char_id, 0)
	var req = get_next_star_req(current_star)
	
	commando_shards[char_id] = commando_shards.get(char_id, 0) - req["shards"]
	if req["clear_items"] > 0:
		clear_items -= req["clear_items"]
	
	commando_stars[char_id] = current_star + 1
	commando_promoted.emit(char_id, current_star + 1)
	shards_changed.emit(char_id, commando_shards[char_id])
	
	if char_id == selected_character_id:
		character_changed.emit(get_selected_stats())
	return true

func add_shards(char_id: String, amount: float) -> void:
	commando_shards[char_id] = commando_shards.get(char_id, 0.0) + amount
	shards_changed.emit(char_id, commando_shards[char_id])

func add_clear_items(amount: float) -> void:
	clear_items += amount

# ==========================================
# User Level & Chapter Clear
# ==========================================
func complete_chapter(chapter_num: int) -> Dictionary:
	# 챕터 완료(15분) 시 유저 레벨 지급 + 클리어 아이템 (3열 4번째) 지급
	var prev_user_lvl = user_level
	var rewarded_user_lvls = chapter_num # 챕터 1 -> 유저 레벨 +1
	user_level += rewarded_user_lvls
	
	var rewarded_clear_items = 1
	clear_items += rewarded_clear_items
	
	var rewarded_coins = 50000.0 * chapter_num
	coins += rewarded_coins
	
	return {
		"prev_level": prev_user_lvl,
		"new_level": user_level,
		"gained_level": rewarded_user_lvls,
		"clear_items": rewarded_clear_items,
		"coins": rewarded_coins
	}

# ==========================================
# Controls & Formatting
# ==========================================
func set_control_scheme_by_index(index: int) -> void:
	if index == 0:
		control_scheme = ControlScheme.WASD
	elif index == 1:
		control_scheme = ControlScheme.ARROWS

func get_movement_vector() -> Vector2:
	var move_vec = Vector2.ZERO
	if control_scheme == ControlScheme.WASD:
		move_vec = Input.get_vector("move_left_wasd", "move_right_wasd", "move_up_wasd", "move_down_wasd")
	else:
		move_vec = Input.get_vector("move_left_arrow", "move_right_arrow", "move_up_arrow", "move_down_arrow")
	
	if move_vec == Vector2.ZERO:
		var raw_x = 0.0
		var raw_y = 0.0
		if control_scheme == ControlScheme.WASD:
			if Input.is_key_pressed(KEY_W): raw_y -= 1.0
			if Input.is_key_pressed(KEY_S): raw_y += 1.0
			if Input.is_key_pressed(KEY_A): raw_x -= 1.0
			if Input.is_key_pressed(KEY_D): raw_x += 1.0
		else:
			if Input.is_key_pressed(KEY_UP): raw_y -= 1.0
			if Input.is_key_pressed(KEY_DOWN): raw_y += 1.0
			if Input.is_key_pressed(KEY_LEFT): raw_x -= 1.0
			if Input.is_key_pressed(KEY_RIGHT): raw_x += 1.0
		move_vec = Vector2(raw_x, raw_y).normalized()
		
	return move_vec

func format_unit(val: float) -> String:
	var abs_val = abs(val)
	if abs_val >= 1e20:
		return "%.2e" % val
	elif abs_val >= 1e16:
		var ky = val / 1e16 # 1경 = 10^16, 200경 = 2e18, 300경 = 3e18
		if fmod(ky, 1.0) == 0.0:
			return "%d경" % int(ky)
		return "%.2f경" % ky
	elif abs_val >= 1e12:
		return "%.1fT" % (val / 1e12)
	elif abs_val >= 1_000_000_000.0:
		var b = val / 1_000_000_000.0
		if fmod(b, 1.0) == 0.0:
			return "%dB" % int(b)
		return "%.1fB" % b
	elif abs_val >= 1_000_000.0:
		var m = val / 1_000_000.0
		if fmod(m, 1.0) == 0.0:
			return "%dM" % int(m)
		return "%.1fM" % m
	elif abs_val >= 1_000.0:
		var k = val / 1_000.0
		if fmod(k, 1.0) == 0.0:
			return "%dk" % int(k)
		return "%.1fk" % k
	else:
		if fmod(val, 1.0) == 0.0:
			return str(int(val))
		return "%.1f" % val

func format_large_number(val) -> String:
	var f = float(val)
	if f >= 1e16:
		return format_unit(f)
	if f > 9.22e18 or f < -9.22e18:
		return format_unit(f)
	var s = str(int(f))
	var result = ""
	var count = 0
	for i in range(s.length() - 1, -1, -1):
		result = s[i] + result
		count += 1
		if count % 3 == 0 and i != 0:
			result = "," + result
	return result

