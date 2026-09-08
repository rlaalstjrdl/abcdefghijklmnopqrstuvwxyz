extends PanelContainer

@onready var control_option: OptionButton = %ControlOption
@onready var auto_attack_check: CheckButton = %AutoAttackCheck
@onready var close_button: Button = %CloseButton

func _ready() -> void:
	_init_ui()
	control_option.item_selected.connect(_on_control_option_selected)
	auto_attack_check.toggled.connect(_on_auto_attack_toggled)
	close_button.pressed.connect(_on_close_button_pressed)

func _init_ui() -> void:
	control_option.clear()
	control_option.add_item("WASD 이동", 0)
	control_option.add_item("방향키(Arrow) 이동", 1)
	
	control_option.select(SettingsManager.control_scheme)
	auto_attack_check.button_pressed = SettingsManager.auto_attack

func _on_control_option_selected(index: int) -> void:
	SettingsManager.set_control_scheme_by_index(index)

func _on_auto_attack_toggled(toggled_on: bool) -> void:
	SettingsManager.auto_attack = toggled_on

func _on_close_button_pressed() -> void:
	hide()
