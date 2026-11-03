extends PanelContainer

@onready var options_container: VBoxContainer = %OptionsContainer

var skill_pool: Array[Dictionary] = [
	{ "id": "atk", "name": "⚔️ 무기 연마", "desc": "공격력 +20%", "type": "atk", "val": 0.2 },
	{ "id": "spd", "name": "⚡ 신속의 부적", "desc": "공격 쿨다운 -15%", "type": "spd", "val": 0.15 },
	{ "id": "mov", "name": "👟 가벼운 발걸음", "desc": "이동 속도 +15%", "type": "mov", "val": 0.15 },
	{ "id": "def", "name": "🛡️ 단단한 갑주", "desc": "방어력 +4", "type": "def", "val": 4.0 },
	{ "id": "hp", "name": "💖 생명력의 성배", "desc": "최대 체력 +30", "type": "hp", "val": 30.0 }
]

func open_chest(count: int = 3) -> void:
	get_tree().paused = true
	show()
	
	for child in options_container.get_children():
		child.queue_free()
	
	var shuffled = skill_pool.duplicate()
	shuffled.shuffle()
	var select_count = min(count, shuffled.size())
	
	for i in range(select_count):
		var skill = shuffled[i]
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(0, 50)
		btn.text = "%s  :  %s" % [skill.name, skill.desc]
		btn.pressed.connect(func(): _on_skill_chosen(skill))
		options_container.add_child(btn)

func _on_skill_chosen(skill: Dictionary) -> void:
	var chapter = get_tree().current_scene
	if chapter and chapter.get("player"):
		var p = chapter.player
		if p and p.stats:
			match skill.type:
				"atk":
					p.stats.attack_power *= (1.0 + skill.val)
				"spd":
					p.stats.attack_cooldown = max(0.2, p.stats.attack_cooldown * (1.0 - skill.val))
				"mov":
					p.stats.move_speed *= (1.0 + skill.val)
				"def":
					p.stats.defense += skill.val
				"hp":
					p.stats.max_hp += skill.val
					p.heal_percent(0.3)
	
	hide()
	get_tree().paused = false
