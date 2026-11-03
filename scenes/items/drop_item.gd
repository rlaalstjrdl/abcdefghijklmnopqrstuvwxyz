class_name DropItem
extends Area2D

enum ItemType {
	XP_GEM_GREEN, # 0: Green gem (+5 XP)
	XP_GEM_BLUE,  # 1: Blue gem (+10 XP)
	XP_GEM_GOLD,  # 2: Gold gem (+30 XP)
	GOLD_COIN,    # 3: Coin (+10 Gold) - 1열 4번째
	GOLD_BAG,     # 5: Gold sack (+100 Gold)
	CHEST,        # 6: Skill Chest
	MAGNET,       # 8: Magnet
	FOOD,         # 9: Meat (Heal 50% HP)
	BOMB,         # 10: Screen Bomb
	XP_GEM,       # Legacy alias for XP_GEM_BLUE
	SHARD_SKELETON, # Frame 12: Skeleton Shard
	SHARD_SOLDIER,  # Frame 13: Soldier Shard
	SHARD_KNIGHT,   # Frame 14: Knight Shard
	CLEAR_ITEM      # Frame 15: Clear Item (3열 4번째)
}

@export var item_type: ItemType = ItemType.XP_GEM_BLUE
@export var move_speed: float = 480.0

var is_being_magnetized: bool = false
var target_player: Node2D = null
var bob_tween: Tween = null

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	add_to_group("drop_items")
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
	_update_visuals()
	_start_floating_animation()

func init_drop_item(type: ItemType, pos: Vector2) -> void:
	item_type = type
	global_position = pos
	is_being_magnetized = false
	target_player = null
	modulate = Color.WHITE
	visible = true
	set_physics_process(true)
	set_deferred("monitoring", true)
	set_deferred("monitorable", true)
	_update_visuals()
	_start_floating_animation()

func recycle() -> void:
	if bob_tween and bob_tween.is_valid():
		bob_tween.kill()
	set_physics_process(false)
	visible = false
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)
	ObjectPool.return_drop_item(self)


func _get_sprite() -> Sprite2D:
	if not sprite or not is_instance_valid(sprite):
		sprite = get_node_or_null("Sprite2D")
	return sprite

func _update_visuals() -> void:
	var spr = _get_sprite()
	if not spr:
		return
		
	match item_type:
		ItemType.XP_GEM_GREEN:
			spr.frame = 0
			spr.scale = Vector2(0.35, 0.35)
		ItemType.XP_GEM_BLUE, ItemType.XP_GEM:
			spr.frame = 1
			spr.scale = Vector2(0.4, 0.4)
		ItemType.XP_GEM_GOLD:
			spr.frame = 2
			spr.scale = Vector2(0.48, 0.48)
		ItemType.GOLD_COIN:
			spr.frame = 3
			spr.scale = Vector2(0.38, 0.38)
		ItemType.GOLD_BAG:
			spr.frame = 5
			spr.scale = Vector2(0.45, 0.45)
		ItemType.CHEST:
			spr.frame = 6
			spr.scale = Vector2(0.5, 0.5)
		ItemType.MAGNET:
			spr.frame = 8
			spr.scale = Vector2(0.45, 0.45)
		ItemType.FOOD:
			spr.frame = 9
			spr.scale = Vector2(0.45, 0.45)
		ItemType.BOMB:
			spr.frame = 10
			spr.scale = Vector2(0.45, 0.45)
		ItemType.SHARD_SKELETON:
			spr.frame = 12
			spr.scale = Vector2(0.42, 0.42)
		ItemType.SHARD_SOLDIER:
			spr.frame = 13
			spr.scale = Vector2(0.42, 0.42)
		ItemType.SHARD_KNIGHT:
			spr.frame = 14
			spr.scale = Vector2(0.42, 0.42)
		ItemType.CLEAR_ITEM:
			spr.frame = 15 # 3열 4번째
			spr.scale = Vector2(0.5, 0.5)
		_:
			spr.frame = 1
			spr.scale = Vector2(0.4, 0.4)

func _start_floating_animation() -> void:
	var spr = _get_sprite()
	if not spr:
		return
		
	if bob_tween and bob_tween.is_valid():
		bob_tween.kill()
		
	# Spawn scale pop-in
	var initial_scale = spr.scale
	spr.scale = initial_scale * 0.2
	var spawn_tween = create_tween()
	spawn_tween.tween_property(spr, "scale", initial_scale, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	# Gentle up/down floating bob
	bob_tween = create_tween().set_loops()
	var random_offset = randf_range(0.0, 0.4)
	bob_tween.tween_interval(random_offset)
	bob_tween.tween_property(spr, "position:y", -4.0, 0.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	bob_tween.tween_property(spr, "position:y", 0.0, 0.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func _physics_process(delta: float) -> void:
	if is_being_magnetized and target_player and is_instance_valid(target_player):
		var dir = (target_player.global_position - global_position).normalized()
		global_position += dir * move_speed * delta

func attract_to(player_node: Node2D) -> void:
	is_being_magnetized = true
	target_player = player_node

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_apply_effect(body)
		recycle()

func _apply_effect(player_node: Node2D) -> void:
	var chapter = get_tree().current_scene
	match item_type:
		ItemType.FOOD:
			if player_node.has_method("heal_percent"):
				player_node.heal_percent(0.5)
			if chapter and chapter.has_method("show_banner"):
				chapter.show_banner("🍗 고기 획득! 최대 체력 50% 회복!", Color(0.3, 1.0, 0.3))
				
		ItemType.MAGNET:
			if chapter and chapter.has_method("trigger_magnet_effect"):
				chapter.trigger_magnet_effect(player_node)
			if chapter and chapter.has_method("show_banner"):
				chapter.show_banner("🧲 자석 발동! 모든 아이템 흡수!", Color(0.3, 0.8, 1.0))
				
		ItemType.CHEST:
			if chapter and chapter.has_method("open_skill_chest"):
				chapter.open_skill_chest()
				
		ItemType.XP_GEM, ItemType.XP_GEM_BLUE:
			if chapter and chapter.has_method("add_xp"):
				chapter.add_xp(10)
				
		ItemType.XP_GEM_GREEN:
			if chapter and chapter.has_method("add_xp"):
				chapter.add_xp(5)
				
		ItemType.XP_GEM_GOLD:
			if chapter and chapter.has_method("add_xp"):
				chapter.add_xp(30)
				
		ItemType.GOLD_COIN:
			SettingsManager.coins += 10
			if chapter and chapter.has_method("show_banner"):
				chapter.show_banner("🪙 골드 +10 획득!", Color(1.0, 0.85, 0.2))
				
		ItemType.GOLD_BAG:
			SettingsManager.coins += 100
			if chapter and chapter.has_method("show_banner"):
				chapter.show_banner("💰 골드 자루 획득! (+100 Gold)", Color(1.0, 0.8, 0.1))
				
		ItemType.SHARD_SKELETON:
			SettingsManager.add_shards("skeleton", 1)
			if chapter and chapter.has_method("show_banner"):
				chapter.show_banner("💀 스켈레톤 조각 +1 획득! (총 %d개)" % SettingsManager.commando_shards.get("skeleton", 0), Color(0.6, 0.8, 1.0))
				
		ItemType.SHARD_SOLDIER:
			SettingsManager.add_shards("soldier", 1)
			if chapter and chapter.has_method("show_banner"):
				chapter.show_banner("🪖 솔저 조각 +1 획득! (총 %d개)" % SettingsManager.commando_shards.get("soldier", 0), Color(0.4, 1.0, 0.5))
				
		ItemType.SHARD_KNIGHT:
			SettingsManager.add_shards("knight", 1)
			if chapter and chapter.has_method("show_banner"):
				chapter.show_banner("🛡️ 기사 조각 +1 획득! (총 %d개)" % SettingsManager.commando_shards.get("knight", 0), Color(1.0, 0.85, 0.3))
				
		ItemType.CLEAR_ITEM:
			SettingsManager.add_clear_items(1)
			if chapter and chapter.has_method("show_banner"):
				chapter.show_banner("🏆 클리어 아이템 +1 획득! (총 %d개)" % SettingsManager.clear_items, Color(1.0, 0.3, 0.3))
				
		ItemType.BOMB:
			if chapter and chapter.has_method("trigger_bomb_effect"):
				chapter.trigger_bomb_effect()
			else:
				var enemies = get_tree().get_nodes_in_group("enemies")
				for enemy in enemies:
					if is_instance_valid(enemy) and enemy.has_method("take_damage"):
						enemy.take_damage(9999.0)
				if chapter and chapter.has_method("show_banner"):
					chapter.show_banner("💣 폭탄 발동! 화면 내 모든 적 처치!", Color(1.0, 0.3, 0.3))
