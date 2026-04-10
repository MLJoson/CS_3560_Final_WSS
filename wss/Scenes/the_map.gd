extends Node2D

enum Terrain {
	GRASS, #1
	DESERT, #2
	MOUNTAIN, #3
	SWAMP #4
}

var terrain_types = [
	preload("res://Assets/GRASS.tscn"),
	preload("res://Assets/DESERT.tscn"),
	preload("res://Assets/MOUNTAIN.tscn"),
	preload("res://Assets/SWAMP.tscn")
]

#change this take in user options
var width = 50
var height = 50
var tile_size = 50

var map = []
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	generate_map()
	spawn_map()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

"""
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
						map[x].append(randi() % terrain_types.size())"""

func generate_map():
	for x in range(width):
		map.append([])
		for y in range(height):
			map[x].append(randi() % terrain_types.size())
			
	for i in range(3):
		smooth_map()

func smooth_map():
	for x in range(width):
		for y in range(height):
			map[x][y] = get_dominant_neighbor(x,y)

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

func spawn_map():
	for x in range(width):
		for y in range(height):
			var terrain_type = map[x][y]
			var tile = terrain_types[terrain_type].instantiate()
			
			tile.position = Vector2(x * tile_size, y * tile_size)
			
			add_child(tile)
