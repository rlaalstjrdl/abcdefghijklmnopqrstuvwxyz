extends Control

@onready var start_btn: Button = %StartButton
@onready var commando_btn: Button = %CommandoButton
@onready var settings_btn: Button = %SettingsButton
@onready var quit_btn: Button = %QuitButton

@onready var settings_menu: PanelContainer = %SettingsMenu
@onready var commando_menu: PanelContainer = %CommandoMenu

@onready var user_level_label: Label = %UserLevelLabel
@onready var coin_icon: TextureRect = %CoinIcon
@onready var coin_label: Label = %CoinLabel
@onready var clear_item_icon: TextureRect = %ClearItemIcon
@onready var clear_item_label: Label = %ClearItemLabel

@onready var char_name_label: Label = %CharName
@onready var char_level_star_label: Label = %CharLevelStarLabel
@onready var star_container: HBoxContainer = %StarContainer
@onready var char_preview: TextureRect = %CharacterPreview
@onready var stats_label: Label = %StatsLabel

func _ready() -> void:
	start_btn.pressed.connect(_on_start_pressed)
	commando_btn.pressed.connect(_on_commando_pressed)
	settings_btn.pressed.connect(_on_settings_pressed)
	quit_btn.pressed.connect(_on_quit_pressed)
	
	settings_menu.hide()
	commando_menu.hide()
	
	if coin_icon:
		coin_icon.texture = SettingsManager.get_coin_texture()
	if clear_item_icon:
		clear_item_icon.texture = SettingsManager.get_clear_item_texture()
	
	SettingsManager.character_changed.connect(_on_character_changed)
	SettingsManager.coins_changed.connect(_on_currency_changed)
	SettingsManager.clear_items_changed.connect(_on_currency_changed)
	SettingsManager.user_level_changed.connect(_on_user_level_changed)
	SettingsManager.commando_upgraded.connect(_on_commando_updated)
	SettingsManager.commando_promoted.connect(_on_commando_updated)
	
	_update_header()
	_display_selected_character()

func _on_currency_changed(_val = null) -> void:
	_update_header()

func _on_user_level_changed(_lvl: int, _xp: int) -> void:
	_update_header()

func _on_commando_updated(_char_id: String, _val: int) -> void:
	_display_selected_character()

func _on_character_changed(_new_stats: CharacterStats) -> void:
	_display_selected_character()
	_update_header()

func _update_header() -> void:
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

func _display_selected_character() -> void:
	var stats: CharacterStats = SettingsManager.get_selected_stats()
	if not stats:
		return
	
	var char_id = SettingsManager.selected_character_id
	var lvl = SettingsManager.commando_levels.get(char_id, 1)
	var star = SettingsManager.commando_stars.get(char_id, 0)
	var star_text = SettingsManager.get_star_display(star)
	var shards = SettingsManager.commando_shards.get(char_id, 0)
	
	char_name_label.text = stats.character_name
	if char_level_star_label:
		char_level_star_label.text = "[ Lv. %d / 150 ]\n조각: %s개" % [lvl, _format_comma(shards)]
	
	if star_container:
		for child in star_container.get_children():
			child.queue_free()
		var stars_ui = SettingsManager.build_stars_container(star, Vector2(20, 20), 4)
		for child in stars_ui.get_children():
			child.reparent(star_container)
		stars_ui.queue_free()
		
	if stats.icon_texture:
		char_preview.texture = stats.icon_texture
	
	stats_label.text = """[ %s 전투 스탯 ]
• 특공대 등급: Lv. %d | %s
• 체력 (HP): %s
• 이동 속도: %s px/s
• 공격력: %s
• 공격 쿨다운: %.2f초
• 사거리: %s px
• 방어력: %s""" % [
		stats.character_name,
		lvl,
		star_text,
		SettingsManager.format_unit(stats.max_hp),
		SettingsManager.format_unit(stats.move_speed),
		SettingsManager.format_unit(stats.attack_power),
		stats.attack_cooldown,
		SettingsManager.format_unit(stats.attack_range),
		SettingsManager.format_unit(stats.defense)
	]

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/chapters/chapter_1.tscn")

func _on_commando_pressed() -> void:
	commando_menu.show()

func _on_settings_pressed() -> void:
	settings_menu.show()

func _on_quit_pressed() -> void:
	get_tree().quit()

func _format_comma(n) -> String:
	return SettingsManager.format_large_number(n)

