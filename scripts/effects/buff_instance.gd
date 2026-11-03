# buff_instance.gd
class_name BuffInstance
extends RefCounted

var id: String = ""
var duration: float = 0.0
var max_duration: float = 0.0
var stacks: int = 1
var tick_timer: float = 0.0

var definition: Dictionary = {}

func _init(buff_id: String, custom_duration: float = -1.0, initial_stacks: int = 1) -> void:
	id = buff_id
	definition = BuffDatabase.get_definition(buff_id)
	if custom_duration > 0.0:
		duration = custom_duration
	else:
		duration = definition.get("default_duration", 5.0)
	max_duration = duration
	stacks = initial_stacks
	tick_timer = 0.0

func is_expired() -> bool:
	return duration <= 0.0

func refresh_duration(new_dur: float = -1.0) -> void:
	if new_dur > 0.0:
		duration = max(duration, new_dur)
		max_duration = max(max_duration, new_dur)
	else:
		duration = definition.get("default_duration", 5.0)
		max_duration = duration

func add_stack(max_stacks: int = 5) -> void:
	stacks = min(max_stacks, stacks + 1)
	refresh_duration()
