class_name BatEnemy
extends CharacterBody2D

@export var max_hp: float = 3.0
@export var speed: float = 135.0
@export var attack_damage: float = 0.5
@export var defense: float = 0.0

var current_hp: float = 3.0
var is_dead: bool = false
var target: Node2D = null
var buff_manager: BuffManager = null

@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	add_to_group("enemies")
	buff_manager = BuffManager.new()
	buff_manager.name = "BuffManager"
	add_child(buff_manager)
	current_hp = max_hp
	scale = Vector2(1.6, 1.6)
	_find_player()

func _find_player() -> void:
	if not is_inside_tree():
		return
	var tree = get_tree()
	if not tree:
		return
	var players = tree.get_nodes_in_group("player")
	if players.size() > 0:
		target = players[0]

func _physics_process(_delta: float) -> void:
	if is_dead:
		return
	
	if buff_manager and (buff_manager.is_stunned or buff_manager.is_frozen):
		velocity = Vector2.ZERO
		return
	
	if not target or not is_instance_valid(target):
		_find_player()
		return
	
	var dir = (target.global_position - global_position).normalized()
	var effective_speed = speed
	if buff_manager:
		effective_speed *= buff_manager.get_speed_multiplier()
	velocity = dir * effective_speed
	move_and_slide()
	
	if dir.x > 0:
		sprite.flip_h = false
	elif dir.x < 0:
		sprite.flip_h = true

func take_damage(amount: float) -> void:
	if is_dead:
		return
	
	var effective_def = defense
	if buff_manager:
		effective_def = (effective_def + buff_manager.get_defense_addition()) * buff_manager.get_defense_multiplier()
		
	var actual_dmg = max(1.0, amount - effective_def)
	if buff_manager:
		actual_dmg *= (1.0 - buff_manager.get_damage_reduction() + buff_manager.get_damage_amplify())
		actual_dmg = max(1.0, actual_dmg)
		
	current_hp -= actual_dmg
	
	modulate = Color(2.0, 0.3, 0.3)
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.1)
	
	if current_hp <= 0:
		die()

func add_buff(buff_id: String, duration: float = -1.0, stacks: int = 1) -> void:
	if buff_manager:
		buff_manager.apply_buff(buff_id, duration, stacks)

func init_bat(pos: Vector2) -> void:
	global_position = pos
	is_dead = false
	current_hp = max_hp
	modulate = Color.WHITE
	visible = true
	set_physics_process(true)
	if buff_manager:
		buff_manager.clear_all_buffs()
	_find_player()

func recycle() -> void:
	if buff_manager:
		buff_manager.clear_all_buffs()
	set_physics_process(false)
	visible = false
	ObjectPool.return_bat(self)


func die() -> void:
	if is_dead:
		return
	is_dead = true
	
	# Emit kill event to Chapter
	if is_inside_tree() and get_tree():
		var chapter = get_tree().current_scene
		if chapter and chapter.has_method("on_enemy_killed"):
			chapter.on_enemy_killed("bat", global_position)
	
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.15)
	tween.tween_callback(recycle)


func _on_hit_box_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and body.has_method("take_damage"):
		body.take_damage(attack_damage)

