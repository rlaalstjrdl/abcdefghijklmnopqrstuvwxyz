# buff_display_hud.gd
class_name BuffDisplayHUD
extends HBoxContainer

var target_player: Player = null
var buff_icons: Dictionary = {} # buff_id -> Control (VBox or Panel)

func _ready() -> void:
	custom_minimum_size = Vector2(400, 48)

func set_target_player(p: Player) -> void:
	target_player = p
	if target_player and target_player.buff_manager:
		target_player.buff_manager.buff_added.connect(_on_buff_added)
		target_player.buff_manager.buff_removed.connect(_on_buff_removed)
		target_player.buff_manager.buff_updated.connect(_on_buff_updated)

func _on_buff_added(buff: BuffInstance) -> void:
	if buff_icons.has(buff.id):
		_on_buff_updated(buff)
		return
	
	var panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(36, 42)
	
	var style = StyleBoxFlat.new()
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_left = 6
	style.corner_radius_bottom_right = 6
	
	if buff.definition.get("is_debuff", false):
		style.bg_color = Color(0.3, 0.05, 0.1, 0.85)
		style.border_color = Color(1.0, 0.3, 0.3, 0.9)
	else:
		style.bg_color = Color(0.05, 0.25, 0.1, 0.85)
		style.border_color = Color(0.3, 1.0, 0.5, 0.9)
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	panel.add_theme_stylebox_override("panel", style)
	
	var vbox = VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	
	var icon_label = Label.new()
	icon_label.text = buff.definition.get("icon", "✨")
	icon_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(icon_label)
	
	var time_label = Label.new()
	time_label.name = "TimeLabel"
	time_label.text = "%.1fs" % buff.duration
	time_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	time_label.add_theme_font_size_override("font_size", 10)
	vbox.add_child(time_label)
	
	panel.add_child(vbox)
	panel.tooltip_text = "[%s]\n%s" % [buff.definition.get("name", ""), buff.definition.get("desc", "")]
	
	add_child(panel)
	buff_icons[buff.id] = panel

func _on_buff_updated(buff: BuffInstance) -> void:
	if not buff_icons.has(buff.id):
		_on_buff_added(buff)
		return
		
	var panel = buff_icons[buff.id]
	var time_lbl = panel.find_child("TimeLabel", true, false) as Label
	if time_lbl:
		time_lbl.text = "%.1fs" % buff.duration

func _on_buff_removed(buff_id: String) -> void:
	if buff_icons.has(buff_id):
		var panel = buff_icons[buff_id]
		buff_icons.erase(buff_id)
		if is_instance_valid(panel):
			panel.queue_free()
