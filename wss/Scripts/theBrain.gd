extends CharacterBody2D
var path = []
var tile_size = 50
var speed = 200

var vision_type
var vision_range
var directions = []
func _ready():
	vision_type = Global.vision
	
	match vision_type:
		"Focused":
			vision_range = 2
			directions = [
				Vector2i(1,0),
				Vector2i(1,1),
				Vector2i(1,-1)
			]
		"Cautious":
			vision_range = 4
			directions = [
				Vector2i(1,0),
				Vector2i(0,1),
				Vector2i(0,-1)
			]
		"Keen-Eyed":
			vision_range = 6
			directions = [
				Vector2i(1,0),
				Vector2i(0,1),
				Vector2i(0,-1),
				Vector2i(1,1),
				Vector2i(1,-1),
				Vector2i(2,0)
			]
		"Far-Sighted":
			vision_range = 8
			directions = [
				Vector2i(1,0),
				Vector2i(0,1),
				Vector2i(0,-1),
				Vector2i(1,1),
				Vector2i(1,-1),
				Vector2i(2,0),
				Vector2i(2,1),
				Vector2i(2,-1),
				Vector2i(0,-2),
				Vector2i(0,2),
				Vector2i(1,-2),
				Vector2i(1,2),
			]

func set_target(target_tile: Vector2i):
	if not is_tile_visible(
		Vector2i(int(position.x / tile_size), int(position.y / tile_size)),
		target_tile):
		return
	
	path = generate_simple_path(target_tile)
	
func generate_simple_path(target: Vector2i):
	var result = []
	var current = Vector2i(
	int(position.x / tile_size),
	int(position.y / tile_size)
	)
	
	# Move in X direction
	while current.x != target.x:
		if target.x > current.x:
			current.x += 1
		else:
			current.x -= 1
		result.append(current)
	
	# Move in Y direction
	while current.y != target.y:
		if target.y > current.y:
			current.y += 1
		else:
			current.y -= 1
		result.append(current)
	
	return result

func _process(delta):
	if path.size() == 0:
		return
	
	var target_tile = path[0]
	var target_pos = Vector2(target_tile.x * tile_size, target_tile.y * tile_size)
	
	var direction = (target_pos - position).normalized()
	position += direction * speed * delta
	
	# Snap when close enough
	if position.distance_to(target_pos) < 5:
		position = target_pos
		path.pop_front() # move to next tile
		get_parent().update_visibility()

func is_tile_visible(player_pos: Vector2i, tile_pos: Vector2i) -> bool:
	var diff = tile_pos - player_pos

	for dir in directions:
		# check if tile is in same general direction
		if sign(diff.x) == sign(dir.x) and sign(diff.y) == sign(dir.y):

			# allow same row/col diagonal grouping
			if abs(diff.x) <= vision_range and abs(diff.y) <= vision_range:
				return true

	return false
