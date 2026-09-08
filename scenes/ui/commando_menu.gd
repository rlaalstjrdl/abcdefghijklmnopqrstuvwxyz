extends PanelContainer

@onready var coin_label: Label = %CoinLabel
@onready var character_list_container: VBoxContainer = %CharacterListContainer
@onready var close_button: Button = %CloseButton

var commando_ids: Array[String] = ["skeleton", "soldier", "knight"]

func _ready() -> void:
	close_button.pressed.connect(_on_close_pressed)
	SettingsManager.coins_changed.connect(_on_coins_changed)
	SettingsManager.character_changed.connect(_on_character_changed)
	_refresh_ui()

func _refresh_ui() -> void:
	coin_label.text = "🪙 보유 코인: %s (%s)" % [
		SettingsManager.format_unit(SettingsManager.coins),
		_format_comma(SettingsManager.coins)
	]
	
	# Clear existing list
	for child in character_list_container.get_children():
		child.queue_free()
	
	for char_id in commando_ids:
		var stats: CharacterStats = SettingsManager.character_roster.get(char_id)
		if not stats:
			continue
		
		var panel = PanelContainer.new()
		var margin = MarginContainer.new()
		margin.add_theme_constant_override("margin_left", 12)
		margin.add_theme_constant_override("margin_right", 12)
		margin.add_theme_constant_override("margin_top", 10)
		margin.add_theme_constant_override("margin_bottom", 10)
		
		var hbox = HBoxContainer.new()
		hbox.add_theme_constant_override("separation", 16)
		
		# Icon
		var icon_rect = TextureRect.new()
		icon_rect.custom_minimum_size = Vector2(80, 80)
		icon_rect.texture = stats.icon_texture
		icon_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		hbox.add_child(icon_rect)
		
		# Info VBox
		var info_vbox = VBoxContainer.new()
		info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		var name_label = Label.new()
		name_label.text = "%s" % stats.character_name
		name_label.add_theme_font_size_override("font_size", 18)
		info_vbox.add_child(name_label)
		
		var desc_label = Label.new()
		desc_label.text = "체력: %s | 공격력: %s | 속도: %s | 쿨다운: %.2fs | 방어: %s" % [
			SettingsManager.format_unit(stats.max_hp),
			SettingsManager.format_unit(stats.attack_power),
			SettingsManager.format_unit(stats.move_speed),
			stats.attack_cooldown,
			SettingsManager.format_unit(stats.defense)
		]
		desc_label.add_theme_font_size_override("font_size", 13)
		desc_label.modulate = Color(0.85, 0.85, 0.9)
		info_vbox.add_child(desc_label)
		
		var price_label = Label.new()
		if stats.price == 0:
			price_label.text = "가격: 기본 지급 (무료)"
		else:
			price_label.text = "가격: %s 코인 (%s)" % [
				SettingsManager.format_unit(stats.price),
				_format_comma(stats.price)
			]
		price_label.add_theme_font_size_override("font_size", 14)
		price_label.modulate = Color(1.0, 0.85, 0.3)
		info_vbox.add_child(price_label)
		
		hbox.add_child(info_vbox)
		
		# Button
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(130, 44)
		btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		
		var is_unlocked = SettingsManager.is_unlocked(char_id)
		var is_selected = SettingsManager.selected_character_id == char_id
		
		if is_selected:
			btn.text = "✓ 출전 중"
			btn.disabled = true
		elif is_unlocked:
			btn.text = "선택하기"
			btn.pressed.connect(func(): _on_select_clicked(char_id))
		else:
			btn.text = "구매하기"
			btn.disabled = (SettingsManager.coins < stats.price)
			btn.pressed.connect(func(): _on_buy_clicked(char_id))
		
		hbox.add_child(btn)
		margin.add_child(hbox)
		panel.add_child(margin)
		character_list_container.add_child(panel)

func _on_buy_clicked(char_id: String) -> void:
	if SettingsManager.purchase_character(char_id):
		SettingsManager.select_character(char_id)
		_refresh_ui()

func _on_select_clicked(char_id: String) -> void:
	if SettingsManager.select_character(char_id):
		_refresh_ui()

func _on_coins_changed(_new_amount: int) -> void:
	_refresh_ui()

func _on_character_changed(_new_stats: CharacterStats) -> void:
	_refresh_ui()

func _on_close_pressed() -> void:
	hide()

func _format_comma(n: int) -> String:
	var s = str(n)
	var result = ""
	var count = 0
	for i in range(s.length() - 1, -1, -1):
		result = s[i] + result
		count += 1
		if count % 3 == 0 and i != 0:
			result = "," + result
	return result
