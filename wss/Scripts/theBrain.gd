extends CharacterBody2D
var path = []
var tile_size = 50
var speed = 200
var vision: Vision

var recommendation = null
#pointer to point at brain-related item
@onready var pointer = $Pointer
func _ready():
	vision = Vision.new()
	add_child(vision) 
	
	vision.setup(Global.vision)
	
	recommendation = find_nearest_desired_item()
	print("Recommended tile: ", recommendation)

func set_target(target_tile: Vector2i):
	if not vision.is_tile_visible(Vector2i(int(position.x / tile_size), int(position.y / tile_size)), target_tile):
		return
	Player.isMoving = true
	path = generate_simple_path(target_tile)
	
func generate_simple_path(target: Vector2i):
	var result = []
	var current = Vector2i(int(position.x / tile_size), int(position.y / tile_size))
	
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
	
	update_pointer()
	if path.size() == 0:
		Player.isMoving = false
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
		update_recommendation()
		print("Target item at: ", recommendation)
		apply_movement_cost(target_tile)
		get_parent().update_visibility()
		get_parent().check_win_condition()

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
		#For items
		if child is Node2D:
			var child_tile = Vector2i(
				int(child.position.x / tile_size),
				int(child.position.y / tile_size))
				
			if child_tile == tile_pos and child.has_method("collect"):
				child.collect()
		#for traders
		if child is BaseTrader:
			var trader_tile = Vector2i(int(child.position.x / tile_size), int(child.position.y / tile_size))
			if trader_tile == tile_pos:
				open_trading_menu(child)

#adding brain functions using polymorphism and inheritance
func get_desired_item_type():
	return null

#get nearest item based on brain
func find_nearest_desired_item():
	
	var desired_type = get_desired_item_type()
	
	if desired_type == null:
		return null
		
	var map = get_parent()
	
	var player_tile = Vector2i(
		int(position.x / tile_size),
		int(position.y / tile_size))
	var closest = null
	
	var closest_distance = INF
	
	for child in map.get_children():
		if child.has_method("get_item_type"):
			if child.get_item_type() == desired_type:
				var item_tile = Vector2i(
					int(child.position.x / tile_size),
					int(child.position.y / tile_size))
				var dist = player_tile.distance_to(item_tile)
				if dist < closest_distance:
					closest_distance = dist
					closest = item_tile
	return closest

func update_recommendation():
	recommendation = find_nearest_desired_item()

func update_pointer():
	if recommendation == null:
		pointer.visible = false
		return
	pointer.visible = true
	var target_pos = get_parent().get_tile_world_position(recommendation)
	var dir = target_pos - global_position
	pointer.rotation = lerp_angle(pointer.rotation, dir.angle() + PI/2, 0.1)

#open trade menu
func open_trading_menu(trader):
	get_tree().paused = true
	var trade_ui = preload("res://Scenes/TraderUI.tscn").instantiate()
	trade_ui.set_trader(trader)
	get_tree().current_scene.add_child(trade_ui)
