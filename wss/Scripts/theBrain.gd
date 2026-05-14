extends CharacterBody2D

# Stores the list of tiles the player will move through.
var path = []

# Size of each map tile in pixels.
var tile_size = 50

# How fast the player moves between tiles.
var speed = 200

# Vision object used to check which tiles the player can see.
var vision: Vision

# Stores the recommended tile based on the player's brain behavior.
var recommendation = null

# Pointer that rotates toward the recommended item.
@onready var pointer = $Pointer

# Runs when the player is added to the scene.
func _ready():
	# Create and add the vision system to this player.
	vision = Vision.new()
	add_child(vision) 
	
	# Set up the vision type using the option selected in the start menu.
	vision.setup(Global.vision)
	
	# Find the nearest item this brain wants and point toward it.
	recommendation = find_nearest_desired_item()
	print("Recommended tile: ", recommendation)

# Sets a tile for the player to move toward.
func set_target(target_tile: Vector2i):
	# Do not move if the target tile is not visible.
	if not vision.is_tile_visible(Vector2i(int(position.x / tile_size), int(position.y / tile_size)), target_tile):
		return
	
	# Mark the player as moving so resting does not happen.
	Player.isMoving = true
	
	# Create a simple path from the current tile to the target tile.
	path = generate_simple_path(target_tile)

# Creates a simple path to the target tile.
# The player moves horizontally first, then vertically.
func generate_simple_path(target: Vector2i):
	var result = []
	var current = Vector2i(int(position.x / tile_size), int(position.y / tile_size))
	
	# Move one tile at a time in the X direction.
	while current.x != target.x:
		if target.x > current.x:
			current.x += 1
		else:
			current.x -= 1
		result.append(current)
	
	# Move one tile at a time in the Y direction.
	while current.y != target.y:
		if target.y > current.y:
			current.y += 1
		else:
			current.y -= 1
		result.append(current)
	
	return result

# Runs every frame.
# Handles movement, item collection, map visibility, and pointer updates.
func _process(delta):
	# Rotate the pointer toward the recommended item.
	update_pointer()
	
	# If there is no path, the player is not moving.
	if path.size() == 0:
		Player.isMoving = false
		return
	
	# Get the next tile in the path.
	var target_tile = path[0]
	var target_pos = Vector2(target_tile.x * tile_size, target_tile.y * tile_size)
	
	# Move toward the next tile.
	var direction = (target_pos - position).normalized()
	position += direction * speed * delta
	
	# Snap to the tile when close enough to prevent sliding past it.
	if position.distance_to(target_pos) < 5:
		position = target_pos
		path.pop_front()
		
		# Collect any item or interact with any trader on this tile.
		collect_item_at_tile(target_tile)
		
		# Update the recommended item after moving or collecting something.
		update_recommendation()
		print("Target item at: ", recommendation)
		
		# Apply the cost of moving onto this tile.
		apply_movement_cost(target_tile)
		
		# Refresh map visibility and check if the player won.
		get_parent().update_visibility()
		get_parent().check_win_condition()

# Applies the movement cost for the terrain on the given tile.
func apply_movement_cost(tile_pos: Vector2i):
	var map = get_parent()
	var terrain = map.map[tile_pos.x][tile_pos.y]
	Player.apply_movement_cost(terrain)

# Collects an item or opens a trade menu if something is on the current tile.
func collect_item_at_tile(tile_pos: Vector2i):
	var map = get_parent()
	
	# Loop through all children in the map scene.
	for child in map.get_children():
		# Check item-like nodes.
		if child is Node2D:
			var child_tile = Vector2i(
				int(child.position.x / tile_size),
				int(child.position.y / tile_size)
			)
				
			# If the child is on this tile and can be collected, collect it.
			if child_tile == tile_pos and child.has_method("collect"):
				child.collect()
		
		# Check trader nodes.
		if child is BaseTrader:
			var trader_tile = Vector2i(
				int(child.position.x / tile_size),
				int(child.position.y / tile_size)
			)
			
			# If the player reaches a trader, open the trading menu.
			if trader_tile == tile_pos:
				open_trading_menu(child)

# Brain function meant to be overridden by child scripts.
# Child brain scripts can return "food", "water", "gold", or another item type.
func get_desired_item_type():
	return null

# Finds the nearest item that matches this brain's desired item type.
func find_nearest_desired_item():
	# Ask the brain what type of item it wants.
	var desired_type = get_desired_item_type()
	
	# If there is no desired type, there is no recommendation.
	if desired_type == null:
		return null
		
	var map = get_parent()
	
	# Find the player's current tile.
	var player_tile = Vector2i(
		int(position.x / tile_size),
		int(position.y / tile_size)
	)
	
	var closest = null
	var closest_distance = INF
	
	# Search through map children for matching items.
	for child in map.get_children():
		if child.has_method("get_item_type"):
			if child.get_item_type() == desired_type:
				var item_tile = Vector2i(
					int(child.position.x / tile_size),
					int(child.position.y / tile_size)
				)
				
				# Keep track of the closest matching item.
				var dist = player_tile.distance_to(item_tile)
				if dist < closest_distance:
					closest_distance = dist
					closest = item_tile
	
	return closest

# Refreshes the recommended target item.
func update_recommendation():
	recommendation = find_nearest_desired_item()

# Updates the pointer so it points toward the recommended item.
func update_pointer():
	# Hide the pointer if there is no recommendation.
	if recommendation == null:
		pointer.visible = false
		return
	
	pointer.visible = true
	
	# Convert the recommended tile into a world position.
	var target_pos = get_parent().get_tile_world_position(recommendation)
	
	# Find the direction from the player to the target.
	var dir = target_pos - global_position
	
	# Smoothly rotate the pointer toward the target item.
	pointer.rotation = lerp_angle(pointer.rotation, dir.angle() + PI / 2, 0.1)

# Opens the trading menu for the trader the player reached.
func open_trading_menu(trader):
	# Pause the game while trading.
	get_tree().paused = true
	
	# Create the trading UI and connect it to this trader.
	var trade_ui = preload("res://Scenes/TraderUI.tscn").instantiate()
	trade_ui.set_trader(trader)
	
	# Add the trading UI to the current scene.
	get_tree().current_scene.add_child(trade_ui)
