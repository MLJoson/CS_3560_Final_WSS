extends Node

# Gives this script a global class name
# This allows other scripts to create and use Vision objects
class_name Vision

# Stores the selected vision type
var vision_type

# Stores the tile offsets the player is allowed to see
# Each offset is relative to the player's current tile position
var offsets = []

# Sets up the vision pattern based on the selected vision type
func setup(type):
	vision_type = type
	
	match vision_type:

		# Focused vision shows the current tile and a small forward cone
		"Focused":
			offsets = [
				Vector2i(0, 0),
				Vector2i(1, 0),
				Vector2i(1, 1),
				Vector2i(1, -1)
			]

		# Cautious vision shows the current tile and nearby tiles in a cross shape
		"Cautious":
			offsets = [
				Vector2i(0, 0),
				Vector2i(1, 0),
				Vector2i(0, 1),
				Vector2i(0, -1)
			]

		# Keen-Eyed vision shows a wider area in front of and around the player
		"Keen-Eyed":
			offsets = [
				Vector2i(0, 0),
				Vector2i(1, 0),
				Vector2i(1, 1),
				Vector2i(1, -1),
				Vector2i(2, 0),
				Vector2i(0, 1),
				Vector2i(0, -1)
			]

		# Far-Sighted vision gives the player the largest visible area
		"Far-Sighted":
			offsets = [
				Vector2i(0, 0),
				Vector2i(1, 0),
				Vector2i(1, 1),
				Vector2i(1, -1),
				Vector2i(2, 0),
				Vector2i(2, 1),
				Vector2i(2, -1),
				Vector2i(0, 1),
				Vector2i(0, -1),
				Vector2i(0, 2),
				Vector2i(0, -2),
				Vector2i(1, 2),
				Vector2i(1, -2)
			]

# Checks whether a specific tile is visible from the player's current position
func is_tile_visible(player_pos: Vector2i, tile_pos: Vector2i) -> bool:
	# Find the tile's position relative to the player
	var diff = tile_pos - player_pos
	
	# The tile is visible if its relative position is included in the vision offsets
	return diff in offsets
