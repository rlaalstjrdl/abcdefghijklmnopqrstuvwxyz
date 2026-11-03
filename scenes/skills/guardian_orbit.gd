class_name GuardianOrbit
extends Node2D

@export var base_damage: float = 18.0
@export var orbit_speed: float = 3.5
@export var orbit_radius: float = 85.0
@export var blade_count: int = 2

var blades: Array[Area2D] = []

func _ready() -> void:
	_create_blades()

func set_level(level: int) -> void:
	blade_count = 2 + (level - 1)
	base_damage = 15.0 + (level * 5.0)
	orbit_radius = 80.0 + (level * 8.0)
	_create_blades()

func _create_blades() -> void:
	for b in blades:
		if is_instance_valid(b):
			b.queue_free()
	blades.clear()
	
	for i in range(blade_count):
		var area = Area2D.new()
		area.collision_layer = 4
		area.collision_mask = 2
		
		var col = CollisionShape2D.new()
		var shape = CircleShape2D.new()
		shape.radius = 14.0
		col.shape = shape
		area.add_child(col)
		
		var label = Label.new()
		label.text = "⚔️"
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.position = Vector2(-12, -14)
		label.add_theme_font_size_override("font_size", 20)
		area.add_child(label)
		
		area.body_entered.connect(func(body): _on_blade_hit(body))
		add_child(area)
		blades.append(area)

func _physics_process(delta: float) -> void:
	rotation += orbit_speed * delta
	for i in range(blades.size()):
		var angle = (TAU / blades.size()) * i
		var pos = Vector2.from_angle(angle) * orbit_radius
		blades[i].position = pos

func _on_blade_hit(body: Node2D) -> void:
	if body.is_in_group("enemies") and body.has_method("take_damage"):
		body.take_damage(base_damage)
