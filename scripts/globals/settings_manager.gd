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

var coins: int = 1500000: # 테스트용 1500k 코인 기본 지급
	set(value):
		coins = value
		coins_changed.emit(coins)

var unlocked_characters: Array[String] = ["skeleton"]
var selected_character_id: String = "skeleton":
	set(value):
		selected_character_id = value
		character_changed.emit(get_selected_stats())

var character_roster: Dictionary = {}

signal settings_changed
signal coins_changed(new_amount: int)
signal character_changed(new_stats: CharacterStats)

func _ready() -> void:
	character_roster["skeleton"] = preload("res://resources/skeleton_stats.tres")
	character_roster["soldier"] = preload("res://resources/soldier_stats.tres")
	character_roster["knight"] = preload("res://resources/knight_stats.tres")

func get_selected_stats() -> CharacterStats:
	if character_roster.has(selected_character_id):
		return character_roster[selected_character_id]
	return character_roster["skeleton"]

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
	if abs_val >= 1_000_000_000.0:
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
