extends Control

@onready var start_btn: Button = %StartButton
@onready var commando_btn: Button = %CommandoButton
@onready var settings_btn: Button = %SettingsButton
@onready var quit_btn: Button = %QuitButton

@onready var settings_menu: PanelContainer = %SettingsMenu
@onready var commando_menu: PanelContainer = %CommandoMenu

@onready var char_name_label: Label = %CharName
@onready var char_preview: TextureRect = %CharacterPreview
@onready var stats_label: Label = %StatsLabel

func _ready() -> void:
	start_btn.pressed.connect(_on_start_pressed)
	commando_btn.pressed.connect(_on_commando_pressed)
	settings_btn.pressed.connect(_on_settings_pressed)
	quit_btn.pressed.connect(_on_quit_pressed)
	
	settings_menu.hide()
	commando_menu.hide()
	
	SettingsManager.character_changed.connect(_on_character_changed)
	_display_selected_character()

func _on_character_changed(_new_stats: CharacterStats) -> void:
	_display_selected_character()

func _display_selected_character() -> void:
	var stats: CharacterStats = SettingsManager.get_selected_stats()
	if not stats:
		return
	
	char_name_label.text = stats.character_name
	if stats.icon_texture:
		char_preview.texture = stats.icon_texture
	
	stats_label.text = """[ %s 스탯 ]
• 체력 (HP): %s
• 이동 속도: %s px/s
• 공격력: %s
• 공격 쿨다운: %.2f초
• 사거리: %s px
• 방어력: %s""" % [
		stats.character_name,
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
