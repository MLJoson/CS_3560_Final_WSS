extends Node2D

# Terrain types used by the map.
# The enum values match the index positions in the terrain_types array.
enum Terrain {
	GRASS,
	DESERT,
	MOUNTAIN,
	SWAMP,
	TUNDRA
}

# Item types used when spawning collectible items.
# The enum values match the index positions in the item_types array.
enum Items {
	FOOD,
	WATER,
	GOLD
}

# Player types.
# This enum is currently not being used, but can be expanded later.
enum Players {
	Default
}

# Preloaded terrain scenes.
# These are used to create the visual map tiles.
var terrain_types = [
	preload("res://Assets/GRASS.tscn"),
	preload("res://Assets/DESERT.tscn"),
	preload("res://Assets/MOUNTAIN.tscn"),
	preload("res://Assets/SWAMP.tscn"),
	preload("res://Assets/TUNDRA.tscn")
]

# Preloaded item scenes.
# These are used when randomly spawning food, water, or gold.
var item_types = [
	preload("res://Assets/FOOD.tscn"),
	preload("res://Assets/WATER.tscn"),
	preload("res://Assets/GOLD.tscn")
]

# Player scenes matched to the brain option chosen in the start menu.
var player_types = {
	"Hungry": preload("res://Assets/hungryPlayer.tscn"),
	"Thirsty": preload("res://Assets/thirstyPlayer.tscn"),
	"Greedy": preload("res://Assets/greedyPlayer.tscn")
}

# Stores the player object after it is created.
var player_instance

# Map settings.
# These are replaced by the values selected in the start menu.
var width = 100
var height = 20
var tile_size = 50

# Stores terrain data for each tile.
var map = []

# Stores the actual tile scene instances.
var tiles = []

# Stores the stats UI instance.
var stats_ui

# Runs when the map scene first loads.
func _ready() -> void:
	# Get map size and settings from the global menu options.
	width = Global.map_width
	height = Global.map_height
	
	# Print selected settings for debugging.
	print("Width:", width)
	print("Height:", height)
	print("Difficulty:", Global.difficulty)
	print("Vision:", Global.vision)
	
	# Create and add the stats UI to the scene.
	stats_ui = preload("res://Scenes/StatsUI.tscn").instantiate()
	add_child(stats_ui)
	
	# Generate the map data, then create the visible map tiles.
	generate_map()
	spawn_map()

# Runs every frame.
# Currently unused.
func _process(delta: float) -> void:
	pass

# Generates the terrain map using simple procedural generation.
# Each tile is influenced by its north and west neighbors.
func generate_map():
	for x in range(width):
		map.append([])
		for y in range(height):
			# Make the top-left starting tile grass.
			if x == 0 and y == 0:
				map[x].append(Terrain.GRASS)
				continue
			
			# Store the north and west neighbor terrain types if they exist.
			var north = null
			var west = null
			
			if y > 0: 
				north = map[x][y - 1]
			
			if x > 0:
				west = map[x - 1][y]
			
			# Random roll used to decide whether to copy a neighbor
			# or choose a random terrain type.
			var roll = randf()
			
			# If both north and west neighbors exist, use them to influence this tile.
			if north != null and west != null:
				# If both neighbors are the same, usually copy that terrain.
				if north == west:
					if roll < 0.9:
						map[x].append(north)
					else:
						map[x].append(randi() % terrain_types.size())
				
				# If the neighbors are different, choose between them or random terrain.
				else:
					if roll < 0.44:
						map[x].append(north)
					elif roll < 0.9:
						map[x].append(west)
					else:
						map[x].append(randi() % terrain_types.size())
			
			# If only the north neighbor exists, usually copy it.
			elif north != null:
				if roll < 0.9:
					map[x].append(north)
				else:
					map[x].append(randi() % terrain_types.size())
			
			# If only the west neighbor exists, usually copy it.
			elif west != null:
				if roll < 0.9:
					map[x].append(west)
				else:
					map[x].append(randi() % terrain_types.size())

	# Smooth the map to reduce noisy terrain changes.
	for i in range(1):
		smooth_map()

# Smooths the map by changing each tile to match its dominant neighboring terrain.
func smooth_map():
	for x in range(width):
		for y in range(height):
			map[x][y] = get_dominant_neighbor(x, y)

# Checks surrounding tiles and returns the most common neighboring terrain type.
func get_dominant_neighbor(x, y):
	var counts = {}
	
	# Check north.
	if y > 0:
		var t = map[x][y - 1]
		counts[t] = counts.get(t, 0) + 1
	
	# Check south.
	if y < height - 1:
		var t = map[x][y + 1]
		counts[t] = counts.get(t, 0) + 1
	
	# Check west.
	if x > 0:
		var t = map[x - 1][y]
		counts[t] = counts.get(t, 0) + 1
	
	# Check east.
	if x < width - 1:
		var t = map[x + 1][y]
		counts[t] = counts.get(t, 0) + 1
		
	# Start with the current tile's terrain as the default best terrain.
	var best_terrain = map[x][y]
	var best_count = -1
	
	# Find which terrain appears the most around this tile.
	for terrain in counts:
		if counts[terrain] > best_count:
			best_count = counts[terrain]
			best_terrain = terrain
	
	return best_terrain

# Tries to randomly spawn an item on this tile.
# Spawn chance depends on difficulty, and item type depends on terrain.
func try_spawn_item(x, y):
	var spawn_chance = 0.05
	
	# Change item spawn chance based on difficulty.
	match Global.difficulty:
		"Easy":
			spawn_chance = 0.1
		"Medium":
			spawn_chance = 0.05
		"Hard":
			spawn_chance = 0.02
			
	# If the random roll fails, do not spawn an item.
	if randf() > spawn_chance:
		return
	
	# Get this tile's terrain and roll for item type.
	var terrain = map[x][y]
	var roll = randf()
	var item_type = -1
	
	# Grass can spawn food, water, or gold evenly.
	if terrain == Terrain.GRASS:
		if roll < 0.33:
			item_type = Items.FOOD
		elif roll < 0.66:
			item_type = Items.WATER
		else:
			item_type = Items.GOLD
	
	# Desert has a higher chance of food or gold, and a lower chance of water.
	elif terrain == Terrain.DESERT:
		if roll < 0.45:
			item_type = Items.FOOD
		elif roll < 0.90:
			item_type = Items.GOLD
		else:
			item_type = Items.WATER
	
	# Mountain has a higher chance of water or gold, and a lower chance of food.
	elif terrain == Terrain.MOUNTAIN:
		if roll < 0.45:
			item_type = Items.WATER
		elif roll < 0.90:
			item_type = Items.GOLD
		else:
			item_type = Items.FOOD
	
	# Swamp has a higher chance of food or water, and a lower chance of gold.
	elif terrain == Terrain.SWAMP:
		if roll < 0.45:
			item_type = Items.FOOD
		elif roll < 0.90:
			item_type = Items.WATER
		else:
			item_type = Items.GOLD
	
	# If no item type was chosen, do not spawn anything.
	if item_type == -1:
		return
	
	# Create the item and place it on the map.
	var item = item_types[item_type].instantiate()
	item.position = Vector2(x * tile_size, y * tile_size)
	add_child(item)

# Tries to randomly spawn a trader on this tile.
func try_spawn_trader(x, y):
	var spawn_chance = 0.01
	
	# Change trader spawn chance based on difficulty.
	match Global.difficulty:
		"Easy":
			spawn_chance = 0.02
		"Medium":
			spawn_chance = 0.01
		"Hard":
			spawn_chance = 0.005
	
	# Do not spawn traders in the first column near the starting side.
	if x == 0:
		return false
	
	# If the random roll fails, do not spawn a trader.
	if randf() > spawn_chance:
		return false
	
	# Spawn the trader and report success.
	spawn_trader(x, y)
	return true

# Creates the visual map tiles, then spawns traders, items, and the player.
func spawn_map():
	for x in range(width):
		tiles.append([])
		for y in range(height):
			# Create the correct terrain tile for this map position.
			var terrain_type = map[x][y]
			var tile = terrain_types[terrain_type].instantiate()
			
			# Position the tile and store its grid location.
			tile.position = Vector2(x * tile_size, y * tile_size)
			tile.grid_pos = Vector2i(x, y)
			
			# Connect tile clicks to this map script.
			tile.connect("tile_clicked", Callable(self, "on_tile_clicked"))
			
			# Add the tile to the scene and store it in the tiles array.
			add_child(tile)
			tiles[x].append(tile)
			
			# Try to spawn a trader first.
			# If no trader spawns, try to spawn an item instead.
			if not try_spawn_trader(x, y):
				try_spawn_item(x, y)

	# Choose a random starting row for the player on the left side of the map.
	var placement = randi_range(0, height - 1)
	
	# Create the player type selected by the brain option.
	player_instance = player_types[Global.brain].instantiate()
	player_instance.position = Vector2(0, placement * tile_size)
	add_child(player_instance)
	
	# Update fog/visibility after the player is placed.
	update_visibility()

# Runs when a map tile is clicked.
func on_tile_clicked(target_tile: Vector2i):
	# Find the player's current tile.
	var player_tile = Vector2i(
		int(player_instance.position.x / tile_size),
		int(player_instance.position.y / tile_size)
	)

	# Ignore clicks on tiles the player cannot currently see.
	if not player_instance.vision.is_tile_visible(player_tile, target_tile):
		return

	# Tell the player to move toward the clicked tile.
	player_instance.set_target(target_tile)

# Updates which tiles, items, and traders are visible to the player.
func update_visibility():
	# Find the player's current tile.
	var player_tile = Vector2i(
		int(player_instance.position.x / tile_size),
		int(player_instance.position.y / tile_size)
	)
	
	# Update terrain tile visibility.
	for x in range(width):
		for y in range(height):
			var tile = tiles[x][y]
			
			if player_instance.vision.is_tile_visible(player_tile, Vector2i(x, y)):
				tile.set_visible_state(true)
			else:
				tile.set_visible_state(false)
	
	# Update item and trader visibility.
	for child in get_children():
		# Items are identified by having get_item_type().
		if child.has_method("get_item_type"):
			var item_tile = Vector2i(
				int(child.position.x / tile_size),
				int(child.position.y / tile_size)
			)
			
			var visible_to_player = player_instance.vision.is_tile_visible(
				player_tile,
				item_tile
			)
			
			child.visible = visible_to_player
		
		# Traders are identified by the BaseTrader class.
		elif child is BaseTrader:
			var trader_tile = Vector2i(
				int(child.position.x / tile_size),
				int(child.position.y / tile_size)
			)
			
			var visible_to_player = player_instance.vision.is_tile_visible(
				player_tile,
				trader_tile
			)
			
			child.visible = visible_to_player
	
	# Print current vision offsets for debugging.
	print(player_instance.vision.offsets)

# Checks if the player has reached the right side of the map.
func check_win_condition():
	var player_tile = Vector2i(
		int(player_instance.position.x / tile_size),
		int(player_instance.position.y / tile_size)
	)
	
	# The player wins by reaching the final column.
	if player_tile.x >= width - 1:
		on_player_win()

# Loads the win scene.
func on_player_win():
	get_tree().change_scene_to_file("res://Scenes/YouWin.tscn")

# Converts a tile coordinate into a world position.
func get_tile_world_position(tile: Vector2i) -> Vector2:
	return Vector2(tile.x * tile_size, tile.y * tile_size)

# Spawns a trader based on the selected difficulty.
func spawn_trader(x, y):
	var traderScene
	
	# Choose trader behavior based on difficulty.
	match Global.difficulty:
		"Easy":
			traderScene = preload("res://Assets/dumbTrader.tscn")
		"Medium":
			traderScene = preload("res://Assets/regularTrader.tscn")
		"Hard":
			traderScene = preload("res://Assets/angryTrader.tscn")
	
	# Create and place the trader.
	var trader = traderScene.instantiate()
	trader.position = Vector2(x * tile_size, y * tile_size)
	add_child(trader)
