extends PanelContainer

@onready var control_option: OptionButton = %ControlOption
@onready var auto_attack_check: CheckButton = %AutoAttackCheck
@onready var coupon_input: LineEdit = %CouponInput
@onready var coupon_redeem_button: Button = %CouponRedeemButton
@onready var coupon_status_label: Label = %CouponStatusLabel
@onready var close_button: Button = %CloseButton

func _ready() -> void:
	_init_ui()
	control_option.item_selected.connect(_on_control_option_selected)
	auto_attack_check.toggled.connect(_on_auto_attack_toggled)
	coupon_redeem_button.pressed.connect(_on_coupon_redeem_pressed)
	if coupon_input:
		coupon_input.text_submitted.connect(func(_text): _on_coupon_redeem_pressed())
	close_button.pressed.connect(_on_close_button_pressed)

func _init_ui() -> void:
	control_option.clear()
	control_option.add_item("WASD 이동", 0)
	control_option.add_item("방향키(Arrow) 이동", 1)
	
	control_option.select(SettingsManager.control_scheme)
	auto_attack_check.button_pressed = SettingsManager.auto_attack
	if coupon_status_label:
		coupon_status_label.text = ""

func _on_control_option_selected(index: int) -> void:
	SettingsManager.set_control_scheme_by_index(index)

func _on_auto_attack_toggled(toggled_on: bool) -> void:
	SettingsManager.auto_attack = toggled_on

func _on_coupon_redeem_pressed() -> void:
	if not coupon_input:
		return
	
	var code = coupon_input.text.strip_edges()
	var result = SettingsManager.redeem_coupon(code)
	
	if coupon_status_label:
		coupon_status_label.text = result["message"]
		if result["success"]:
			coupon_status_label.modulate = Color(0.3, 1.0, 0.4)
			coupon_input.text = ""
		else:
			coupon_status_label.modulate = Color(1.0, 0.4, 0.4)

func _on_close_button_pressed() -> void:
	if coupon_status_label:
		coupon_status_label.text = ""
	hide()

