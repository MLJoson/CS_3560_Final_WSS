extends CharacterBody2D
var path = []
var tile_size = 50
var speed = 200
var vision: Vision


func _ready():
	vision = Vision.new()
	add_child(vision) 
	
	vision.setup(Global.vision)

func set_target(target_tile: Vector2i):
	if not vision.is_tile_visible(
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
