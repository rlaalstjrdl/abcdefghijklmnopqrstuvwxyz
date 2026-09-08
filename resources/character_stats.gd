class_name CharacterStats
extends Resource

@export var character_name: String = "Skeleton"
@export var max_hp: float = 100.0
@export var move_speed: float = 180.0
@export var attack_power: float = 25.0
@export var attack_cooldown: float = 0.8
@export var attack_range: float = 300.0
@export var pickup_range: float = 90.0
@export var defense: float = 0.0

func create_runtime_copy() -> CharacterStats:
	var copy = duplicate() as CharacterStats
	return copy
