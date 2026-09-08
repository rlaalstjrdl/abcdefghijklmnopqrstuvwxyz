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

signal settings_changed

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
	
	# Fallback if unconfigured input actions are triggered
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
