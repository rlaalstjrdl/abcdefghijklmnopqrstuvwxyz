extends PanelContainer

@onready var cards_container: HBoxContainer = %CardsContainer
@onready var title_label: Label = %TitleLabel

func open_level_up(available_options: Array[Dictionary]) -> void:
	get_tree().paused = true
	show()
	
	for child in cards_container.get_children():
		child.queue_free()
	
	var count = min(3, available_options.size())
	for i in range(count):
		var opt = available_options[i]
		_create_skill_card(opt)

func _create_skill_card(opt: Dictionary) -> void:
	var panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(220, 300)
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_bottom", 16)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	
	# Icon
	var icon_lbl = Label.new()
	icon_lbl.text = opt.get("icon", "✨")
	icon_lbl.add_theme_font_size_override("font_size", 44)
	icon_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(icon_lbl)
	
	# Type Tag
	var type_lbl = Label.new()
	if opt.type == "weapon":
		type_lbl.text = "⚔️ [무기 스킬]"
		type_lbl.modulate = Color(1.0, 0.4, 0.4)
	else:
		type_lbl.text = "🛡️ [지원 스킬]"
		type_lbl.modulate = Color(0.4, 0.8, 1.0)
	type_lbl.add_theme_font_size_override("font_size", 13)
	type_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(type_lbl)
	
	# Name
	var name_lbl = Label.new()
	name_lbl.text = opt.name
	name_lbl.add_theme_font_size_override("font_size", 18)
	name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(name_lbl)
	
	# Level badge
	var cur_lv = opt.get("current_level", 0)
	var next_lv = opt.get("next_level", 1)
	var lv_lbl = Label.new()
	if cur_lv == 0:
		lv_lbl.text = "★ NEW! (Lv. 1)"
		lv_lbl.modulate = Color(1.0, 0.9, 0.2)
	else:
		lv_lbl.text = "Lv. %d ➔ Lv. %d" % [cur_lv, next_lv]
		lv_lbl.modulate = Color(0.3, 1.0, 0.5)
	lv_lbl.add_theme_font_size_override("font_size", 14)
	lv_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(lv_lbl)
	
	# Description
	var desc_lbl = Label.new()
	desc_lbl.text = opt.desc
	desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_lbl.add_theme_font_size_override("font_size", 13)
	desc_lbl.size_flags_vertical = Control.SIZE_EXPAND_FILL
	desc_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(desc_lbl)
	
	# Select Button
	var btn = Button.new()
	btn.text = "선택하기"
	btn.custom_minimum_size = Vector2(0, 38)
	btn.pressed.connect(func(): _on_card_selected(opt.id))
	vbox.add_child(btn)
	
	margin.add_child(vbox)
	panel.add_child(margin)
	cards_container.add_child(panel)

func _on_card_selected(skill_id: String) -> void:
	var chapter = get_tree().current_scene
	if chapter and chapter.get("player"):
		var p = chapter.player
		if p and p.has_method("upgrade_skill"):
			p.upgrade_skill(skill_id)
	
	hide()
	get_tree().paused = false
