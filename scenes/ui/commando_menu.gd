extends PanelContainer

@onready var user_level_label: Label = %UserLevelLabel
@onready var coin_icon: TextureRect = %CoinIcon
@onready var coin_label: Label = %CoinLabel
@onready var clear_item_icon: TextureRect = %ClearItemIcon
@onready var clear_item_label: Label = %ClearItemLabel

@onready var character_list_container: VBoxContainer = %CharacterListContainer
@onready var close_button: Button = %CloseButton

var commando_ids: Array[String] = ["skeleton", "soldier", "knight"]

func _ready() -> void:
	close_button.pressed.connect(_on_close_pressed)
	
	if coin_icon:
		coin_icon.texture = SettingsManager.get_coin_texture()
	if clear_item_icon:
		clear_item_icon.texture = SettingsManager.get_clear_item_texture()
	
	SettingsManager.coins_changed.connect(_on_currency_changed)
	SettingsManager.clear_items_changed.connect(_on_currency_changed)
	SettingsManager.user_level_changed.connect(_on_user_level_changed)
	SettingsManager.character_changed.connect(_on_character_changed)
	SettingsManager.commando_upgraded.connect(_on_commando_updated)
	SettingsManager.commando_promoted.connect(_on_commando_updated)
	SettingsManager.shards_changed.connect(_on_shards_changed)
	
	_refresh_ui()

func _on_currency_changed(_val = null) -> void:
	_refresh_ui()

func _on_user_level_changed(_lvl: int, _xp: int) -> void:
	_refresh_ui()

func _on_character_changed(_new_stats: CharacterStats) -> void:
	_refresh_ui()

func _on_commando_updated(_char_id: String, _val: int) -> void:
	_refresh_ui()

func _on_shards_changed(_char_id: String, _val: int) -> void:
	_refresh_ui()

func _refresh_ui() -> void:
	if user_level_label:
		user_level_label.text = "🎖️ 유저 Lv. %d" % SettingsManager.user_level
	if coin_label:
		coin_label.text = "%s (%s)" % [
			SettingsManager.format_unit(SettingsManager.coins),
			_format_comma(int(SettingsManager.coins))
		]
	if clear_item_label:
		if SettingsManager.clear_items >= 10000:
			clear_item_label.text = "%s개 (%s)" % [
				SettingsManager.format_unit(float(SettingsManager.clear_items)),
				_format_comma(SettingsManager.clear_items)
			]
		else:
			clear_item_label.text = "%s개" % _format_comma(SettingsManager.clear_items)
	
	# Clear existing list
	for child in character_list_container.get_children():
		child.queue_free()
	
	for char_id in commando_ids:
		var base_stats: CharacterStats = SettingsManager.character_roster.get(char_id)
		if not base_stats:
			continue
		
		var effective_stats: CharacterStats = SettingsManager.get_effective_stats(char_id)
		var is_unlocked = SettingsManager.is_unlocked(char_id)
		var is_selected = SettingsManager.selected_character_id == char_id
		var current_lvl = SettingsManager.commando_levels.get(char_id, 1)
		var current_star = SettingsManager.commando_stars.get(char_id, 0)
		var current_shards = SettingsManager.commando_shards.get(char_id, 0)
		var star_display = SettingsManager.get_star_display(current_star)
		
		var panel = PanelContainer.new()
		var margin = MarginContainer.new()
		margin.add_theme_constant_override("margin_left", 14)
		margin.add_theme_constant_override("margin_right", 14)
		margin.add_theme_constant_override("margin_top", 10)
		margin.add_theme_constant_override("margin_bottom", 10)
		
		var hbox = HBoxContainer.new()
		hbox.add_theme_constant_override("separation", 14)
		
		# Icon
		var icon_rect = TextureRect.new()
		icon_rect.custom_minimum_size = Vector2(76, 76)
		icon_rect.texture = base_stats.icon_texture
		icon_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		hbox.add_child(icon_rect)
		
		# Info VBox
		var info_vbox = VBoxContainer.new()
		info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		info_vbox.add_theme_constant_override("separation", 3)
		
		# Header: Name + Level + Star Icons
		var header_hbox = HBoxContainer.new()
		header_hbox.add_theme_constant_override("separation", 10)
		header_hbox.alignment = BoxContainer.ALIGNMENT_BEGIN
		
		var name_label = Label.new()
		name_label.text = "%s   [ Lv. %d/150 ]" % [base_stats.character_name, current_lvl]
		name_label.add_theme_font_size_override("font_size", 16)
		header_hbox.add_child(name_label)
		
		var star_icons_box = SettingsManager.build_stars_container(current_star, Vector2(18, 18), 3)
		header_hbox.add_child(star_icons_box)
		
		info_vbox.add_child(header_hbox)
		
		# Stats Line
		var stats_line = Label.new()
		stats_line.text = "체력: %s | 공격력: %s | 속도: %s | 쿨다운: %.2fs | 방어: %s" % [
			SettingsManager.format_unit(effective_stats.max_hp),
			SettingsManager.format_unit(effective_stats.attack_power),
			SettingsManager.format_unit(effective_stats.move_speed),
			effective_stats.attack_cooldown,
			SettingsManager.format_unit(effective_stats.defense)
		]
		stats_line.add_theme_font_size_override("font_size", 12)
		stats_line.modulate = Color(0.85, 0.9, 1.0)
		info_vbox.add_child(stats_line)
		
		# Shards & Star Promotion Info
		var shard_info_label = Label.new()
		var next_star_req = SettingsManager.get_next_star_req(current_star)
		if current_star >= 20:
			shard_info_label.text = "🏆 최고 성급 도달 (빨간 10성 / 총 20성 마스터!)"
			shard_info_label.modulate = Color(1.0, 0.4, 0.4)
		elif not next_star_req.is_empty():
			var req_shards = next_star_req["shards"]
			var req_clear_items = next_star_req["clear_items"]
			if req_clear_items > 0:
				shard_info_label.text = "다음 승급(%s): 조각 %s / %s개 | 🏆 클리어 아이템 %s / %s개" % [
					next_star_req["star"],
					_format_comma(current_shards),
					_format_comma(req_shards),
					_format_comma(SettingsManager.clear_items),
					_format_comma(req_clear_items)
				]
				shard_info_label.modulate = Color(1.0, 0.45, 0.45) if (current_shards >= req_shards and SettingsManager.clear_items >= req_clear_items) else Color(0.9, 0.75, 0.75)
			else:
				shard_info_label.text = "다음 승급(%s): 조각 %s / %s개" % [
					next_star_req["star"],
					_format_comma(current_shards),
					_format_comma(req_shards)
				]
				shard_info_label.modulate = Color(1.0, 0.9, 0.3) if (current_shards >= req_shards) else Color(0.75, 0.85, 0.85)
		shard_info_label.add_theme_font_size_override("font_size", 12)
		info_vbox.add_child(shard_info_label)
		
		# Price info (if locked)
		if not is_unlocked:
			var price_label = Label.new()
			price_label.text = "잠금 해제 비용: %s 코인 (%s)" % [
				SettingsManager.format_unit(base_stats.price),
				_format_comma(base_stats.price)
			]
			price_label.add_theme_font_size_override("font_size", 12)
			price_label.modulate = Color(1.0, 0.8, 0.2)
			info_vbox.add_child(price_label)
		
		hbox.add_child(info_vbox)
		
		# Action Buttons Column
		var actions_vbox = VBoxContainer.new()
		actions_vbox.custom_minimum_size = Vector2(170, 0)
		actions_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
		actions_vbox.add_theme_constant_override("separation", 6)
		
		# 1. Level Upgrade Button
		var lvl_btn = Button.new()
		lvl_btn.custom_minimum_size = Vector2(170, 28)
		lvl_btn.add_theme_font_size_override("font_size", 12)
		
		if not is_unlocked:
			lvl_btn.text = "레벨업 (미보유)"
			lvl_btn.disabled = true
		elif current_lvl >= 150:
			lvl_btn.text = "최고 레벨 (Lv.150)"
			lvl_btn.disabled = true
		else:
			var cost = SettingsManager.get_upgrade_cost(current_lvl)
			lvl_btn.text = "▲ Lv Up (%s 코인)" % SettingsManager.format_unit(cost)
			lvl_btn.disabled = (SettingsManager.coins < cost)
			lvl_btn.pressed.connect(func(): _on_upgrade_clicked(char_id))
		actions_vbox.add_child(lvl_btn)
		
		# 2. Star Promotion Button
		var star_btn = Button.new()
		star_btn.custom_minimum_size = Vector2(170, 28)
		star_btn.add_theme_font_size_override("font_size", 12)
		
		if not is_unlocked:
			star_btn.text = "승급 (미보유)"
			star_btn.disabled = true
		elif current_star >= 20:
			star_btn.text = "★ 최고 성급"
			star_btn.disabled = true
		else:
			var can_prom = SettingsManager.can_promote_commando(char_id)
			var is_red = (current_star >= 10)
			star_btn.text = " 빨간별 승급" if is_red else " 성급 승급"
			star_btn.icon = SettingsManager.get_star_red_texture() if is_red else SettingsManager.get_star_texture()
			star_btn.expand_icon = true
			star_btn.disabled = not can_prom
			star_btn.pressed.connect(func(): _on_promote_clicked(char_id))
		actions_vbox.add_child(star_btn)
		
		# 3. Select / Purchase Button
		var main_btn = Button.new()
		main_btn.custom_minimum_size = Vector2(170, 28)
		main_btn.add_theme_font_size_override("font_size", 12)
		
		if is_selected:
			main_btn.text = "✓ 출전 중"
			main_btn.disabled = true
		elif is_unlocked:
			main_btn.text = "특공대 선택"
			main_btn.pressed.connect(func(): _on_select_clicked(char_id))
		else:
			main_btn.text = "구매 (%s)" % SettingsManager.format_unit(base_stats.price)
			main_btn.disabled = (SettingsManager.coins < base_stats.price)
			main_btn.pressed.connect(func(): _on_buy_clicked(char_id))
		actions_vbox.add_child(main_btn)
		
		hbox.add_child(actions_vbox)
		margin.add_child(hbox)
		panel.add_child(margin)
		character_list_container.add_child(panel)

func _on_upgrade_clicked(char_id: String) -> void:
	if SettingsManager.upgrade_commando(char_id):
		_refresh_ui()

func _on_promote_clicked(char_id: String) -> void:
	if SettingsManager.promote_commando(char_id):
		_refresh_ui()

func _on_buy_clicked(char_id: String) -> void:
	if SettingsManager.purchase_character(char_id):
		SettingsManager.select_character(char_id)
		_refresh_ui()

func _on_select_clicked(char_id: String) -> void:
	if SettingsManager.select_character(char_id):
		_refresh_ui()

func _on_close_pressed() -> void:
	hide()

func _format_comma(n) -> String:
	return SettingsManager.format_large_number(n)
