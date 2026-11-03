# buff_manager.gd
class_name BuffManager
extends Node

signal buff_added(buff_instance: BuffInstance)
signal buff_removed(buff_id: String)
signal buff_updated(buff_instance: BuffInstance)

var active_buffs: Dictionary = {} # buff_id -> BuffInstance
var target_entity: Node2D = null

# 캐시된 최종 보정치
var stat_multipliers: Dictionary = {}
var stat_additions: Dictionary = {}

var is_stunned: bool = false
var is_frozen: bool = false
var is_silenced: bool = false
var blind_chance: float = 0.0

func _ready() -> void:
	target_entity = get_parent() as Node2D

func _process(delta: float) -> void:
	if active_buffs.is_empty():
		return
	
	var to_remove: Array[String] = []
	
	for buff_id in active_buffs.keys():
		var buff: BuffInstance = active_buffs[buff_id]
		buff.duration -= delta
		
		# DoT(지속 피해) 또는 HoT(지속 회복) 처리 (매 1초마다 틱)
		var stat = buff.definition.get("stat", -1)
		if stat == BuffDatabase.StatType.DOT_DAMAGE or stat == BuffDatabase.StatType.HEAL_OVER_TIME:
			buff.tick_timer += delta
			if buff.tick_timer >= 1.0:
				buff.tick_timer -= 1.0
				_process_tick(buff)
		
		if buff.is_expired():
			to_remove.append(buff_id)
		else:
			buff_updated.emit(buff)
	
	for id in to_remove:
		remove_buff(id)

func _process_tick(buff: BuffInstance) -> void:
	if not target_entity or not is_instance_valid(target_entity):
		return
	if target_entity.get("is_dead"):
		return
	
	var stat = buff.definition.get("stat", -1)
	var mod_val = buff.definition.get("modifier", 0.0) * buff.stacks
	
	if stat == BuffDatabase.StatType.DOT_DAMAGE:
		if target_entity.has_method("take_damage"):
			target_entity.take_damage(mod_val)
	elif stat == BuffDatabase.StatType.HEAL_OVER_TIME:
		if target_entity.has_method("heal_percent"):
			# 고정 체력 회복일 경우
			if target_entity.get("stats") and target_entity.stats.max_hp > 0:
				target_entity.heal_percent(mod_val / target_entity.stats.max_hp)
		elif target_entity.get("current_hp") != null and target_entity.get("max_hp") != null:
			target_entity.current_hp = min(target_entity.max_hp, target_entity.current_hp + mod_val)

func apply_buff(buff_id: String, duration: float = -1.0, stacks: int = 1) -> void:
	if not BuffDatabase.BUFF_DEFS.has(buff_id):
		push_warning("Unknown buff_id: %s" % buff_id)
		return
	
	if active_buffs.has(buff_id):
		var existing: BuffInstance = active_buffs[buff_id]
		existing.refresh_duration(duration)
		existing.stacks = min(5, existing.stacks + stacks)
		buff_updated.emit(existing)
	else:
		var new_buff = BuffInstance.new(buff_id, duration, stacks)
		active_buffs[buff_id] = new_buff
		buff_added.emit(new_buff)
	
	_recalculate_modifiers()
	_update_visual_tint()

func remove_buff(buff_id: String) -> void:
	if active_buffs.has(buff_id):
		active_buffs.erase(buff_id)
		buff_removed.emit(buff_id)
		_recalculate_modifiers()
		_update_visual_tint()

func clear_all_buffs() -> void:
	active_buffs.clear()
	_recalculate_modifiers()
	_update_visual_tint()

func has_buff(buff_id: String) -> bool:
	return active_buffs.has(buff_id)

func _recalculate_modifiers() -> void:
	stat_multipliers.clear()
	stat_additions.clear()
	is_stunned = false
	is_frozen = false
	is_silenced = false
	blind_chance = 0.0
	
	for buff in active_buffs.values():
		var stat = buff.definition.get("stat", -1)
		var is_mult = buff.definition.get("is_mult", false)
		var mod = buff.definition.get("modifier", 0.0) * buff.stacks
		
		match stat:
			BuffDatabase.StatType.STUN:
				is_stunned = true
			BuffDatabase.StatType.FREEZE:
				is_frozen = true
			BuffDatabase.StatType.SILENCE:
				is_silenced = true
			BuffDatabase.StatType.BLIND:
				blind_chance = max(blind_chance, mod)
			_:
				if is_mult:
					stat_multipliers[stat] = stat_multipliers.get(stat, 1.0) + mod
				else:
					stat_additions[stat] = stat_additions.get(stat, 0.0) + mod

func get_speed_multiplier() -> float:
	if is_stunned or is_frozen:
		return 0.0
	return max(0.1, stat_multipliers.get(BuffDatabase.StatType.MOVE_SPEED, 1.0))

func get_attack_multiplier() -> float:
	return max(0.1, stat_multipliers.get(BuffDatabase.StatType.ATTACK_POWER, 1.0))

func get_attack_power_multiplier() -> float:
	return get_attack_multiplier()

func get_attack_addition() -> float:
	return stat_additions.get(BuffDatabase.StatType.ATTACK_POWER, 0.0)

func get_cooldown_multiplier() -> float:
	return max(0.2, stat_multipliers.get(BuffDatabase.StatType.ATTACK_COOLDOWN, 1.0))

func get_defense_addition() -> float:
	return stat_additions.get(BuffDatabase.StatType.DEFENSE, 0.0)

func get_defense_multiplier() -> float:
	return max(0.0, stat_multipliers.get(BuffDatabase.StatType.DEFENSE, 1.0))

func get_damage_reduction() -> float:
	return stat_additions.get(BuffDatabase.StatType.DAMAGE_REDUCTION, 0.0)

func get_damage_amplify() -> float:
	return stat_additions.get(BuffDatabase.StatType.DAMAGE_AMPLIFY, 0.0)

func get_crit_chance_addition() -> float:
	return stat_additions.get(BuffDatabase.StatType.CRIT_CHANCE, 0.0)

func get_crit_damage_addition() -> float:
	return stat_additions.get(BuffDatabase.StatType.CRIT_DAMAGE, 0.0)

func get_dodge_chance() -> float:
	return clamp(stat_additions.get(BuffDatabase.StatType.DODGE_CHANCE, 0.0), 0.0, 0.75)

func get_gold_multiplier() -> float:
	return max(0.1, 1.0 + stat_additions.get(BuffDatabase.StatType.GOLD_GAIN, 0.0))

func get_xp_multiplier() -> float:
	return max(0.1, 1.0 + stat_additions.get(BuffDatabase.StatType.XP_GAIN, 0.0))

func get_pickup_range_multiplier() -> float:
	return max(0.2, stat_multipliers.get(BuffDatabase.StatType.PICKUP_RANGE, 1.0))

func get_active_buffs_list() -> Array[BuffInstance]:
	var list: Array[BuffInstance] = []
	for b in active_buffs.values():
		list.append(b)
	return list

func _update_visual_tint() -> void:
	if not target_entity or not is_instance_valid(target_entity):
		return
	
	if active_buffs.is_empty():
		target_entity.modulate = Color.WHITE
		return
	
	# 디버프가 우선적으로 색상 표출, 없으면 버프 색상 합성
	var has_debuff = false
	var final_color = Color.WHITE
	
	for buff in active_buffs.values():
		if buff.definition.get("is_debuff", false):
			has_debuff = true
			final_color = buff.definition.get("color", Color(0.8, 0.2, 0.8))
			break
	
	if not has_debuff:
		for buff in active_buffs.values():
			final_color = buff.definition.get("color", Color(1.0, 1.0, 0.5))
			break
			
	target_entity.modulate = final_color
