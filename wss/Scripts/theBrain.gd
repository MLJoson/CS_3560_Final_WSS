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
			vision_range = 1
			directions = [
				Vector2i(1,0),
				Vector2i(1,1),
				Vector2i(1,-1)
			]
		"Cautious":
			vision_range = 1
			directions = [
				Vector2i(1,0),
				Vector2i(0,1),
				Vector2i(0,-1)
			]
		"Keen-Eyed":
			vision_range = 1
			directions = [
				Vector2i(1,0),
				Vector2i(0,1),
				Vector2i(0,-1),
				Vector2i(1,1),
				Vector2i(1,-1),
				Vector2i(2,0)
			]
		"Far-Sighted":
			vision_range = 1
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
	
	#Snap when close enough
	if position.distance_to(target_pos) < 5:
		position = target_pos
		path.pop_front() # move to next tile
		collect_item_at_tile(target_tile)
		apply_movement_cost(target_tile)
		get_parent().update_visibility()

#get the movement cost of the movement per step
func apply_movement_cost(tile_pos: Vector2i):
	var map = get_parent()
	var terrain = map.map[tile_pos.x][tile_pos.y]
	Player.apply_movement_cost(terrain)

#get the visible and clickable tiles
func get_visible_offsets():
	var tiles = []

	for dir in directions:
		for i in range(1, vision_range + 1):
			var base = dir * i
			tiles.append(base)

			# widen shape
			tiles.append(base + Vector2i(0,1))
			tiles.append(base + Vector2i(0,-1))

	return tiles

func is_tile_visible(player_pos: Vector2i, tile_pos: Vector2i) -> bool:
	var diff = tile_pos - player_pos
	return diff in get_visible_offsets()

#collect and item if there is one
func collect_item_at_tile(tile_pos: Vector2i):
	var map = get_parent()
	
	# loop through children to find items at this tile
	for child in map.get_children():
		if child is Node2D:
			var child_tile = Vector2i(
				int(child.position.x / tile_size),
				int(child.position.y / tile_size))
				
			if child_tile == tile_pos and child.has_method("collect"):
				child.collect()
