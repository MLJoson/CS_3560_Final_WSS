extends Node2D

enum Terrain {
	GRASS, #1
	DESERT, #2
	MOUNTAIN, #3
	SWAMP #4
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
	preload("res://Assets/SWAMP.tscn")
]

var item_types = [
	preload("res://Assets/FOOD.tscn"),
	preload("res://Assets/WATER.tscn"),
	preload("res://Assets/GOLD.tscn")
]

var player_types= [
	preload("res://Assets/thePlayer.tscn")
]

#player instanace
var player_instance

#change this take in user options
var width = 100
var height = 20
var tile_size = 50

var map = []
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	generate_map()
	spawn_map()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

""""""
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
"""
#creates a map of random generation
func generate_map():
	for x in range(width):
		map.append([])
		for y in range(height):
			map[x].append(randi() % terrain_types.size())
			
	for i in range(3):
		smooth_map()"""

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

#creates the map with the tiles and adds the terrain tiles to each of them
func spawn_map():
	for x in range(width):
		for y in range(height):
			var terrain_type = map[x][y]
			var tile = terrain_types[terrain_type].instantiate()
			
			tile.position = Vector2(x * tile_size, y * tile_size)
			tile.connect("tile_clicked", Callable(self, "on_tile_clicked"))
			add_child(tile)
			
			#spawn items
			try_spawn_item(x,y)
			
	# Place player into the map
	var placement = randi_range(0, height-1)
	player_instance = player_types[0].instantiate()
	player_instance.position = Vector2(0, placement * tile_size)
	add_child(player_instance)

# get position when user clicks button
func on_tile_clicked(target_tile: Vector2i):
	player_instance.set_target(target_tile)
