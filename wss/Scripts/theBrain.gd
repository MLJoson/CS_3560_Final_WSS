extends CharacterBody2D
var path = []
var tile_size = 50
var speed = 200

@onready var brain = $theBrain

func set_target(target_tile: Vector2i):
	path = generate_simple_path(target_tile)
	
func generate_simple_path(target: Vector2i):
	var result = []
	var current = Vector2i(position.x / tile_size, position.y / tile_size)
	
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
