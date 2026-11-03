extends Area2D

@export var speed: float = 400.0
@export var damage: float = 25.0
@export var max_range: float = 105.0 # 이미지 크기(100x100) 만큼만 사거리 제한

var direction: Vector2 = Vector2.RIGHT
var start_position: Vector2
var traveled_distance: float = 0.0

func _ready() -> void:
	start_position = global_position
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
	if not area_entered.is_connected(_on_area_entered):
		area_entered.connect(_on_area_entered)

func init_projectile(pos: Vector2, dir: Vector2, dmg: float) -> void:
	global_position = pos
	start_position = pos
	traveled_distance = 0.0
	damage = dmg
	set_target_direction(dir)
	visible = true
	set_physics_process(true)
	set_deferred("monitoring", true)
	set_deferred("monitorable", true)

func _physics_process(delta: float) -> void:
	var move_delta = speed * delta
	position += direction * move_delta
	traveled_distance += move_delta
	
	if traveled_distance >= max_range:
		recycle()

func set_target_direction(dir: Vector2) -> void:
	direction = dir.normalized()
	rotation = direction.angle()

func recycle() -> void:
	set_physics_process(false)
	visible = false
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)
	ObjectPool.return_projectile(self)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies"):
		if body.has_method("take_damage"):
			body.take_damage(damage)
		# 타격 임팩트 이펙트 소환
		ObjectPool.spawn_impact_effect(global_position, "yellow", Vector2(1.5, 1.5))
		if body.has_method("add_buff"):
			# 타격 시 일정 확률로 한기, 화상, 출혈 등의 디버프 중 하나 부여
			var roll = randf()
			if roll < 0.20:
				var debuffs = ["debuff_chill", "debuff_burn", "debuff_bleed", "debuff_slow_mud", "debuff_corrosive_acid"]
				var chosen = debuffs[randi() % debuffs.size()]
				body.add_buff(chosen)
		recycle()

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemies"):
		if area.has_method("take_damage"):
			area.take_damage(damage)
		# 타격 임팩트 이펙트 소환
		ObjectPool.spawn_impact_effect(global_position, "yellow", Vector2(1.5, 1.5))
		if area.has_method("add_buff"):
			var roll = randf()
			if roll < 0.20:
				var debuffs = ["debuff_chill", "debuff_burn", "debuff_bleed", "debuff_slow_mud"]
				var chosen = debuffs[randi() % debuffs.size()]
				area.add_buff(chosen)
		recycle()

