extends Control

@export var character_stats: CharacterStats = preload("res://resources/skeleton_stats.tres")

@onready var start_btn: Button = %StartButton
@onready var settings_btn: Button = %SettingsButton
@onready var quit_btn: Button = %QuitButton
@onready var settings_menu: PanelContainer = %SettingsMenu

@onready var stats_label: Label = %StatsLabel

func _ready() -> void:
	start_btn.pressed.connect(_on_start_pressed)
	settings_btn.pressed.connect(_on_settings_pressed)
	quit_btn.pressed.connect(_on_quit_pressed)
	settings_menu.hide()
	
	_display_character_stats()

func _display_character_stats() -> void:
	if character_stats and stats_label:
		stats_label.text = """[ %s 기본 스탯 ]
• 체력 (HP): %d
• 이동 속도: %d px/s
• 공격력: %d
• 공격 쿨다운: %.2f초
• 탐색/사거리: %d px
• 방어력: %d""" % [
			character_stats.character_name,
			int(character_stats.max_hp),
			int(character_stats.move_speed),
			int(character_stats.attack_power),
			character_stats.attack_cooldown,
			int(character_stats.attack_range),
			int(character_stats.defense)
		]

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/chapters/chapter_1.tscn")

func _on_settings_pressed() -> void:
	settings_menu.show()

func _on_quit_pressed() -> void:
	get_tree().quit()
