extends Node

# Preloaded scenes
var projectile_scene: PackedScene = preload("res://scenes/entities/projectile.tscn")
var drop_item_scene: PackedScene = preload("res://scenes/items/drop_item.tscn")
var slime_scene: PackedScene = preload("res://scenes/entities/slime_enemy.tscn")
var bat_scene: PackedScene = preload("res://scenes/entities/bat_enemy.tscn")
var generic_enemy_scene: PackedScene = preload("res://scenes/entities/generic_enemy.tscn")
var impact_effect_scene: PackedScene = preload("res://scenes/effects/impact_effect.tscn")

# Pools
var projectile_pool: Array[Node] = []
var drop_item_pool: Array[Node] = []
var slime_pool: Array[Node] = []
var bat_pool: Array[Node] = []
var generic_enemy_pool: Array[Node] = []
var impact_effect_pool: Array[Node] = []

# Pool container nodes to keep scene hierarchy clean
var pool_container: Node = null

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_create_pool_container()

func _create_pool_container() -> void:
	if not pool_container or not is_instance_valid(pool_container):
		pool_container = Node.new()
		pool_container.name = "PoolContainer"
		add_child(pool_container)

# ==========================================
# Projectile Pooling
# ==========================================
func spawn_projectile(pos: Vector2, dir: Vector2, dmg: float, parent: Node) -> Node:
	var proj: Node = null
	while projectile_pool.size() > 0:
		var candidate = projectile_pool.pop_back()
		if is_instance_valid(candidate):
			proj = candidate
			break
	
	if not proj:
		proj = projectile_scene.instantiate()
		proj.set_meta("in_pool", true)
	
	if proj.get_parent() != parent:
		if proj.get_parent():
			proj.get_parent().remove_child(proj)
		parent.call_deferred("add_child", proj)
	
	if proj.has_method("init_projectile"):
		proj.init_projectile(pos, dir, dmg)
	else:
		proj.global_position = pos
		proj.damage = dmg
		proj.set_target_direction(dir)
		proj.visible = true
		proj.set_physics_process(true)
	
	return proj

func return_projectile(proj: Node) -> void:
	if not is_instance_valid(proj):
		return
	if proj in projectile_pool:
		return
	
	proj.set_physics_process(false)
	proj.visible = false
	projectile_pool.append(proj)

# ==========================================
# DropItem Pooling
# ==========================================
func spawn_drop_item(type: int, pos: Vector2, parent: Node) -> Node:
	var item: Node = null
	while drop_item_pool.size() > 0:
		var candidate = drop_item_pool.pop_back()
		if is_instance_valid(candidate):
			item = candidate
			break
	
	if not item:
		item = drop_item_scene.instantiate()
		item.set_meta("in_pool", true)
	
	if item.get_parent() != parent:
		if item.get_parent():
			item.get_parent().remove_child(item)
		parent.call_deferred("add_child", item)
	
	if item.has_method("init_drop_item"):
		item.init_drop_item(type, pos)
	else:
		item.item_type = type
		item.global_position = pos
		item.visible = true
		item.set_physics_process(true)
	
	return item

func return_drop_item(item: Node) -> void:
	if not is_instance_valid(item):
		return
	if item in drop_item_pool:
		return
	
	item.set_physics_process(false)
	item.visible = false
	drop_item_pool.append(item)

# ==========================================
# Slime Pooling
# ==========================================
func spawn_slime(pos: Vector2, split_lvl: int, parent: Node) -> Node:
	var slime: Node = null
	while slime_pool.size() > 0:
		var candidate = slime_pool.pop_back()
		if is_instance_valid(candidate):
			slime = candidate
			break
	
	if not slime:
		slime = slime_scene.instantiate()
		slime.set_meta("in_pool", true)
	
	if slime.get_parent() != parent:
		if slime.get_parent():
			slime.get_parent().remove_child(slime)
		parent.call_deferred("add_child", slime)
	
	if slime.has_method("init_slime"):
		slime.init_slime(pos, split_lvl)
	else:
		slime.split_level = split_lvl
		slime.global_position = pos
		slime.visible = true
		slime.set_physics_process(true)
	
	return slime

func return_slime(slime: Node) -> void:
	if not is_instance_valid(slime):
		return
	if slime in slime_pool:
		return
	
	slime.set_physics_process(false)
	slime.visible = false
	slime_pool.append(slime)

# ==========================================
# Bat Pooling
# ==========================================
func spawn_bat(pos: Vector2, parent: Node) -> Node:
	var bat: Node = null
	while bat_pool.size() > 0:
		var candidate = bat_pool.pop_back()
		if is_instance_valid(candidate):
			bat = candidate
			break
	
	if not bat:
		bat = bat_scene.instantiate()
		bat.set_meta("in_pool", true)
	
	if bat.get_parent() != parent:
		if bat.get_parent():
			bat.get_parent().remove_child(bat)
		parent.call_deferred("add_child", bat)
	
	if bat.has_method("init_bat"):
		bat.init_bat(pos)
	else:
		bat.global_position = pos
		bat.visible = true
		bat.set_physics_process(true)
	
	return bat

func return_bat(bat: Node) -> void:
	if not is_instance_valid(bat):
		return
	if bat in bat_pool:
		return
	
	bat.set_physics_process(false)
	bat.visible = false
	bat_pool.append(bat)

# ==========================================
# Generic Enemy Pooling
# ==========================================
func spawn_generic_enemy(cfg: Dictionary, pos: Vector2, parent: Node) -> Node:
	var enemy: Node = null
	while generic_enemy_pool.size() > 0:
		var candidate = generic_enemy_pool.pop_back()
		if is_instance_valid(candidate):
			enemy = candidate
			break
	
	if not enemy:
		enemy = generic_enemy_scene.instantiate()
		enemy.set_meta("in_pool", true)
	
	if enemy.get_parent() != parent:
		if enemy.get_parent():
			enemy.get_parent().remove_child(enemy)
		parent.call_deferred("add_child", enemy)
	
	if enemy.has_method("setup_enemy"):
		enemy.setup_enemy(cfg, pos)
	else:
		enemy.global_position = pos
		enemy.visible = true
		enemy.set_physics_process(true)
	
	return enemy

func return_generic_enemy(enemy: Node) -> void:
	if not is_instance_valid(enemy):
		return
	if enemy in generic_enemy_pool:
		return
	
	enemy.set_physics_process(false)
	enemy.visible = false
	generic_enemy_pool.append(enemy)

# ==========================================
# Impact Effect Pooling
# ==========================================
func spawn_impact_effect(pos: Vector2, color_type: String = "yellow", scale_val: Vector2 = Vector2(1.5, 1.5), parent: Node = null) -> Node:
	if parent == null:
		parent = get_tree().current_scene
	var effect: Node = null
	while impact_effect_pool.size() > 0:
		var candidate = impact_effect_pool.pop_back()
		if is_instance_valid(candidate):
			effect = candidate
			break
	
	if not effect:
		effect = impact_effect_scene.instantiate()
		effect.set_meta("in_pool", true)
	
	if effect.get_parent() != parent:
		if effect.get_parent():
			effect.get_parent().remove_child(effect)
		parent.add_child(effect)
	
	if effect.has_method("play_impact"):
		effect.play_impact(pos, color_type, scale_val)
	else:
		effect.global_position = pos
		effect.visible = true
	
	return effect

func return_impact_effect(effect: Node) -> void:
	if not is_instance_valid(effect):
		return
	if effect in impact_effect_pool:
		return
	effect.visible = false
	impact_effect_pool.append(effect)

# ==========================================
# Cleanup
# ==========================================
func clear_all() -> void:
	for p in projectile_pool:
		if is_instance_valid(p):
			p.queue_free()
	projectile_pool.clear()
	
	for d in drop_item_pool:
		if is_instance_valid(d):
			d.queue_free()
	drop_item_pool.clear()
	
	for s in slime_pool:
		if is_instance_valid(s):
			s.queue_free()
	slime_pool.clear()
	
	for b in bat_pool:
		if is_instance_valid(b):
			b.queue_free()
	bat_pool.clear()

	for g in generic_enemy_pool:
		if is_instance_valid(g):
			g.queue_free()
	generic_enemy_pool.clear()

	for imp in impact_effect_pool:
		if is_instance_valid(imp):
			imp.queue_free()
	impact_effect_pool.clear()
