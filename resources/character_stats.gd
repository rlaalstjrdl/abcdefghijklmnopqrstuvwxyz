class_name CharacterStats
extends Resource

@export var character_id: String = "skeleton"
@export var character_name: String = "스켈레톤 (Skeleton)"
@export var price: int = 0
@export var max_hp: float = 100.0
@export var move_speed: float = 190.0
@export var attack_power: float = 30.0
@export var attack_cooldown: float = 0.75
@export var attack_range: float = 320.0
@export var pickup_range: float = 100.0
@export var defense: float = 2.0
@export var icon_texture: Texture2D
@export var sprite_frames: SpriteFrames

func create_runtime_copy() -> CharacterStats:
	return duplicate() as CharacterStats
