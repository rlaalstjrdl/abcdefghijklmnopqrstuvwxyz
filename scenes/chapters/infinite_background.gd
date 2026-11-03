class_name InfiniteBackground
extends Node2D

@export var tile_size: float = 96.0

var player: Node2D = null
var bg_sprite: Sprite2D = null

const VIEW_W: float = 3200.0
const VIEW_H: float = 2000.0

func _ready() -> void:
	z_index = -10
	_setup_background_sprite()

func _setup_background_sprite() -> void:
	var tex = _generate_checker_texture()
	bg_sprite = Sprite2D.new()
	bg_sprite.name = "BGSprite"
	bg_sprite.texture = tex
	bg_sprite.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	bg_sprite.region_enabled = true
	bg_sprite.region_rect = Rect2(0, 0, VIEW_W, VIEW_H)
	bg_sprite.centered = true
	add_child(bg_sprite)

func _generate_checker_texture() -> ImageTexture:
	var size = int(tile_size * 2)
	var half = int(tile_size)
	var img = Image.create(size, size, false, Image.FORMAT_RGBA8)
	
	var col_1 = Color(0.09, 0.11, 0.14, 1.0)
	var col_2 = Color(0.11, 0.13, 0.17, 1.0)
	var line_col = Color(0.14, 0.17, 0.22, 0.6)
	
	for y in range(size):
		for x in range(size):
			var tx = 0 if x < half else 1
			var ty = 0 if y < half else 1
			var is_even = (tx + ty) % 2 == 0
			var c = col_1 if is_even else col_2
			
			# Border line on tile edges
			var lx = x % half
			var ly = y % half
			if lx == 0 or ly == 0:
				c = line_col
				
			img.set_pixel(x, y, c)
			
	return ImageTexture.create_from_image(img)

func _process(_delta: float) -> void:
	if not player or not is_instance_valid(player):
		var players = get_tree().get_nodes_in_group("player")
		if not players.is_empty():
			player = players[0]
		return
	
	global_position = player.global_position
	if bg_sprite:
		bg_sprite.region_rect = Rect2(
			player.global_position.x - (VIEW_W * 0.5),
			player.global_position.y - (VIEW_H * 0.5),
			VIEW_W,
			VIEW_H
		)
