extends Node2D

enum Terrain {
	GRASS, #1
	DESERT, #2
	MOUNTAIN, #3
	SWAMP, #4
	TUNDRA #5
}

enum Items {
	FOOD,
	WATER,
	GOLD
}

enum Players{
	Default
}

var terrain_types = [
	preload("res://Assets/GRASS.tscn"),
	preload("res://Assets/DESERT.tscn"),
	preload("res://Assets/MOUNTAIN.tscn"),
	preload("res://Assets/SWAMP.tscn"),
	preload("res://Assets/TUNDRA.tscn")
]

var item_types = [
	preload("res://Assets/FOOD.tscn"),
	preload("res://Assets/WATER.tscn"),
	preload("res://Assets/GOLD.tscn")
]

var player_types = {
	"Hungry": preload("res://Assets/hungryPlayer.tscn"),
	"Thirsty": preload("res://Assets/thirstyPlayer.tscn"),
	"Greedy": preload("res://Assets/greedyPlayer.tscn")
}

#player instanace
var player_instance

#change this take in user options
var width = 100
var height = 20
var tile_size = 50

var map = []
var tiles = []

var stats_ui

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#getting info from menu
	width = Global.map_width
	height = Global.map_height
	
	print("Width:", width)
	print("Height:", height)
	print("Difficulty:", Global.difficulty)
	print("Vision:", Global.vision)
	stats_ui = preload("res://Scenes/StatsUI.tscn").instantiate()
	add_child(stats_ui)
	generate_map()
	spawn_map()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# This is use procedural generation based on neighbors
func generate_map():
	
	for x in range(width):
		map.append([])
		for y in range(height):
			if x == 0 and y == 0:
				map[x].append(Terrain.GRASS)
				continue
			
			# Checking neighbor process by getting the north and west tile
			var north = null
			var west = null
			
			if y > 0: 
				north = map[x][y-1]
			
			if x > 0:
				west = map[x-1][y]
			
			# Roll a random number 0-1
			var roll = randf()
			
			# If both neithbors exist
			if north != null and west != null:
				#north and west are the same
				if north == west:
					if roll < 0.9:
						map[x].append(north)
					else:
						map[x].append(randi() % terrain_types.size())
				#north and west are different
				else:
					if roll < 0.44:
						map[x].append(north)
					elif roll < 0.9:
						map[x].append(west)
					else:
						map[x].append(randi() % terrain_types.size())
			
			# Only north exists
			elif north != null:
					if roll < 0.9:
						map[x].append(north)
					else:
						map[x].append(randi() % terrain_types.size())
			
			# Only west exists
			elif west != null:
					if roll < 0.9:
						map[x].append(west)
					else:
						map[x].append(randi() % terrain_types.size())
	for i in range(1):
		smooth_map()


#smooths the map to reduce randomness
func smooth_map():
	for x in range(width):
		for y in range(height):
			map[x][y] = get_dominant_neighbor(x,y)

#gets the surround tiles and determines it's tile based on it
func get_dominant_neighbor(x, y):
	var counts = {}
	
	# check north
	if y > 0:
		var t = map[x][y - 1]
		counts[t] = counts.get(t, 0) + 1
	
	# check south
	if y < height - 1:
		var t = map[x][y + 1]
		counts[t] = counts.get(t, 0) + 1
	
	# check west
	if x > 0:
		var t = map[x - 1][y]
		counts[t] = counts.get(t, 0) + 1
	
	# check east
	if x < width - 1:
		var t = map[x + 1][y]
		counts[t] = counts.get(t, 0) + 1
		
	var best_terrain = map[x][y]
	var best_count = -1
	
	for terrain in counts:
		if counts[terrain] > best_count:
			best_count = counts[terrain]
			best_terrain = terrain
	
	return best_terrain

#spawning items, it will depended on terrain and rng chance
func try_spawn_item(x,y):
	var spawn_chance = 0.05
	
	#change chance based on difficulty
	match Global.difficulty:
		"Easy":
			spawn_chance = 0.1
		"Medium":
			spawn_chance = 0.05
		"Hard":
			spawn_chance = 0.02
			
	#if didn't get it, skip
	if randf() > spawn_chance:
		return
	
	#get info on tile
	var terrain = map[x][y]
	var roll = randf()
	var item_type = -1
	
	#grass terrain possibilities: chance for all
	if terrain == Terrain.GRASS:
		if roll < 0.33:
			item_type = Items.FOOD
		elif roll < 0.66:
			item_type = Items.WATER
		else:
			item_type = Items.GOLD
	#desert terrain: higher chance for food or gold
	elif terrain == Terrain.DESERT:
		if roll < 0.45:
			item_type = Items.FOOD
		elif roll < 0.90:
			item_type = Items.GOLD
		else:
			item_type = Items.WATER
	#mountain: higher chance for gold or water
	elif terrain == Terrain.MOUNTAIN:
		if roll < 0.45:
			item_type = Items.WATER
		elif roll < 0.90:
			item_type = Items.GOLD
		else:
			item_type = Items.FOOD
	#swamp: higher chance for water or food
	elif terrain == Terrain.SWAMP:
		if roll < 0.45:
			item_type = Items.FOOD
		elif roll < 0.90:
			item_type = Items.WATER
		else:
			item_type = Items.GOLD
	
	#spawn item
	if item_type == -1:
		return
	
	var item = item_types[item_type].instantiate()
	item.position = Vector2(x * tile_size, y * tile_size)
	add_child(item)

#attempting to spawn trader
func try_spawn_trader(x, y):
	var spawn_chance = 0.01
	match Global.difficulty:
		"Easy":
			spawn_chance = 0.02
		"Medium":
			spawn_chance = 0.01
		"Hard":
			spawn_chance = 0.005
	# don't spawn on starting tile
	if x == 0:
		return false
	# RNG fail
	if randf() > spawn_chance:
		return false
	spawn_trader(x, y)
	return true

#creates the map with the tiles and adds the terrain tiles to each of them
func spawn_map():
	for x in range(width):
		tiles.append([])
		for y in range(height):
			var terrain_type = map[x][y]
			var tile = terrain_types[terrain_type].instantiate()
			
			tile.position = Vector2(x * tile_size, y * tile_size)
			tile.grid_pos = Vector2i(x, y)
			tile.connect("tile_clicked", Callable(self, "on_tile_clicked"))
			
			add_child(tile)
			tiles[x].append(tile)
			
			if not try_spawn_trader(x, y):
				try_spawn_item(x, y)

	var placement = randi_range(0, height-1)
	player_instance = player_types[Global.brain].instantiate()
	player_instance.position = Vector2(0, placement * tile_size)
	add_child(player_instance)
	update_visibility()

# get position when user clicks button
func on_tile_clicked(target_tile: Vector2i):
	var player_tile = Vector2i(
		int(player_instance.position.x / tile_size),
		int(player_instance.position.y / tile_size))

	if not player_instance.vision.is_tile_visible(player_tile, target_tile):
		return

	player_instance.set_target(target_tile)
func update_visibility():
	var player_tile = Vector2i(
	int(player_instance.position.x / tile_size),
	int(player_instance.position.y / tile_size))
	
	# Update tile visibility
	for x in range(width):
		for y in range(height):
			var tile = tiles[x][y]
			
			if player_instance.vision.is_tile_visible(player_tile, Vector2i(x,y)):
				tile.set_visible_state(true)
			else:
				tile.set_visible_state(false)
	# Item + trader visibility
	for child in get_children():
		# ITEMS
		if child.has_method("get_item_type"):
			var item_tile = Vector2i(
				int(child.position.x / tile_size),
				int(child.position.y / tile_size))
			var visible_to_player = player_instance.vision.is_tile_visible(
				player_tile,
				item_tile)
			child.visible = visible_to_player
		# TRADERS
		elif child is BaseTrader:
			var trader_tile = Vector2i(
				int(child.position.x / tile_size),
				int(child.position.y / tile_size))
			var visible_to_player = player_instance.vision.is_tile_visible(
				player_tile,
				trader_tile)
			child.visible = visible_to_player
	print(player_instance.vision.offsets)

#win conditioning check
func check_win_condition():
	var player_tile = Vector2i(
		int(player_instance.position.x / tile_size),
		int(player_instance.position.y / tile_size))
	if player_tile.x >= width - 1:
		on_player_win()

func on_player_win():
	get_tree().change_scene_to_file("res://Scenes/YouWin.tscn")

func get_tile_world_position(tile: Vector2i) -> Vector2:
	return Vector2(tile.x * tile_size, tile.y * tile_size)

#trader spawning
func spawn_trader(x, y):
	var traderScene
	match Global.difficulty:
		"Easy":
			traderScene = preload("res://Assets/dumbTrader.tscn")
		"Medium":
			traderScene = preload("res://Assets/regularTrader.tscn")
		"Hard":
			traderScene = preload("res://Assets/angryTrader.tscn")
	var trader = traderScene.instantiate()
	trader.position = Vector2(x * tile_size, y * tile_size)
	add_child(trader)
