extends Node2D

@export var enemy_scene: PackedScene = preload("res://scenes/entities/enemy.tscn")
@onready var player: Player = $Player
@onready var hp_progress_bar: ProgressBar = %HPProgressBar
@onready var time_label: Label = %TimeLabel
@onready var settings_menu: PanelContainer = %SettingsMenu
@onready var spawn_timer: Timer = $SpawnTimer

var elapsed_time: float = 0.0

func _ready() -> void:
	if player:
		player.hp_changed.connect(_on_player_hp_changed)
		player.player_died.connect(_on_player_died)
	
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	settings_menu.hide()

func _process(delta: float) -> void:
	elapsed_time += delta
	var total_sec: int = floori(elapsed_time)
	@warning_ignore("integer_division")
	var minutes: int = total_sec / 60
	var seconds: int = total_sec % 60
	time_label.text = "%02d:%02d" % [minutes, seconds]
	
	if Input.is_action_just_pressed("ui_cancel"):
		_toggle_settings()

func _on_player_hp_changed(current: float, maximum: float) -> void:
	hp_progress_bar.max_value = maximum
	hp_progress_bar.value = current

func _on_player_died() -> void:
	spawn_timer.stop()
	time_label.text += " (GAME OVER)"

func _on_spawn_timer_timeout() -> void:
	if not player or not is_instance_valid(player) or player.is_dead:
		return
	
	if enemy_scene:
		var enemy = enemy_scene.instantiate()
		var random_angle = randf() * TAU
		var spawn_offset = Vector2.from_angle(random_angle) * randf_range(400.0, 550.0)
		enemy.global_position = player.global_position + spawn_offset
		add_child(enemy)

func _toggle_settings() -> void:
	settings_menu.visible = not settings_menu.visible

func _on_settings_btn_pressed() -> void:
	_toggle_settings()

func _on_lobby_btn_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
