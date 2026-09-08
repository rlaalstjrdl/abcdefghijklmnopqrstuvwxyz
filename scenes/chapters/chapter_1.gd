extends Node2D

@export var slime_scene: PackedScene = preload("res://scenes/entities/slime_enemy.tscn")
@export var lancer_scene: PackedScene = preload("res://scenes/entities/lancer_enemy.tscn")
@export var necromancer_scene: PackedScene = preload("res://scenes/entities/necromancer_boss.tscn")

@onready var player: Player = $Player
@onready var hp_progress_bar: ProgressBar = %HPProgressBar
@onready var hp_label: Label = %HPLabel
@onready var time_label: Label = %TimeLabel
@onready var announcement_label: Label = %AnnouncementLabel
@onready var settings_menu: PanelContainer = %SettingsMenu
@onready var slime_spawn_timer: Timer = $SlimeSpawnTimer

var elapsed_time: float = 0.0
var last_lancer_spawn_minute_mark: int = 0
var necromancer_spawned: bool = false

func _ready() -> void:
	if player:
		player.hp_changed.connect(_on_player_hp_changed)
		player.player_died.connect(_on_player_died)
	
	slime_spawn_timer.timeout.connect(_on_slime_spawn_timer_timeout)
	settings_menu.hide()
	announcement_label.text = ""

func _process(delta: float) -> void:
	elapsed_time += delta
	var total_sec: int = floori(elapsed_time)
	@warning_ignore("integer_division")
	var minutes: int = total_sec / 60
	var seconds: int = total_sec % 60
	time_label.text = "%02d:%02d" % [minutes, seconds]
	
	_check_timed_spawns(total_sec)
	
	if Input.is_action_just_pressed("ui_cancel"):
		_toggle_settings()

func _check_timed_spawns(total_sec: int) -> void:
	# 1) Lancer (2분 = 120초마다 중간 보스 등장)
	@warning_ignore("integer_division")
	var current_2min_cycle = total_sec / 120
	if current_2min_cycle > 0 and current_2min_cycle > last_lancer_spawn_minute_mark:
		last_lancer_spawn_minute_mark = current_2min_cycle
		_spawn_lancer_miniboss()
	
	# 2) Necromancer (15분 = 900초 이상부터 단일 보스 등장)
	if total_sec >= 900 and not necromancer_spawned:
		necromancer_spawned = true
		_spawn_necromancer_boss()

func _spawn_slime() -> void:
	if not player or not is_instance_valid(player) or player.is_dead:
		return
	if slime_scene:
		var slime: SlimeEnemy = slime_scene.instantiate()
		slime.split_level = 1
		slime.global_position = _get_spawn_position(450.0, 600.0)
		add_child(slime)

func _spawn_lancer_miniboss() -> void:
	if not player or not is_instance_valid(player) or player.is_dead:
		return
	if lancer_scene:
		var lancer = lancer_scene.instantiate()
		lancer.global_position = _get_spawn_position(500.0, 650.0)
		add_child(lancer)
		_show_announcement("⚠ 중간 보스 [랜서] 등장! ⚠", Color(1.0, 0.6, 0.2))

func _spawn_necromancer_boss() -> void:
	if not player or not is_instance_valid(player) or player.is_dead:
		return
	if necromancer_scene:
		var boss = necromancer_scene.instantiate()
		boss.global_position = _get_spawn_position(550.0, 700.0)
		add_child(boss)
		_show_announcement("☠ 최종 보스 [네크로맨서] 등장! ☠", Color(1.0, 0.2, 0.2))

func _get_spawn_position(min_dist: float, max_dist: float) -> Vector2:
	var angle = randf() * TAU
	var dist = randf_range(min_dist, max_dist)
	return player.global_position + Vector2.from_angle(angle) * dist

func _show_announcement(text: String, col: Color) -> void:
	announcement_label.text = text
	announcement_label.modulate = col
	var tween = create_tween()
	tween.tween_property(announcement_label, "modulate:a", 1.0, 0.3)
	tween.tween_interval(3.0)
	tween.tween_property(announcement_label, "modulate:a", 0.0, 0.8)

func _on_slime_spawn_timer_timeout() -> void:
	_spawn_slime()

func _on_player_hp_changed(current: float, maximum: float) -> void:
	hp_progress_bar.max_value = maximum
	hp_progress_bar.value = current
	if hp_label:
		hp_label.text = "HP: %s / %s" % [SettingsManager.format_unit(max(0, current)), SettingsManager.format_unit(maximum)]

func _on_player_died() -> void:
	slime_spawn_timer.stop()
	time_label.text += " (GAME OVER)"
	_show_announcement("💀 작전 실패 (YOU DIED) 💀", Color.RED)

func _toggle_settings() -> void:
	settings_menu.visible = not settings_menu.visible

func _on_settings_btn_pressed() -> void:
	_toggle_settings()

func _on_lobby_btn_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
