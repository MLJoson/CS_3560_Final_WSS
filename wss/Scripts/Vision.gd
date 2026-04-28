extends Node
class_name Vision

var vision_type
var offsets = []

func setup(type):
	vision_type = type
	
	match vision_type:

		# small forward cone
		"Focused":
			offsets = [
				Vector2i(0,0),
				Vector2i(1,0),
				Vector2i(1,1),
				Vector2i(1,-1)
			]

		# cross shape
		"Cautious":
			offsets = [
				Vector2i(0,0),
				Vector2i(1,0),
				Vector2i(0,1),
				Vector2i(0,-1)
			]

		# wider block
		"Keen-Eyed":
			offsets = [
				Vector2i(0,0),
				Vector2i(1,0),
				Vector2i(1,1),
				Vector2i(1,-1),
				Vector2i(2,0),
				Vector2i(0,1),
				Vector2i(0,-1)
			]

		# large vision
		"Far-Sighted":
			offsets = [
				Vector2i(0,0),
				Vector2i(1,0),
				Vector2i(1,1),
				Vector2i(1,-1),
				Vector2i(2,0),
				Vector2i(2,1),
				Vector2i(2,-1),
				Vector2i(0,1),
				Vector2i(0,-1),
				Vector2i(0,2),
				Vector2i(0,-2),
				Vector2i(1,2),
				Vector2i(1,-2),
			]

func is_tile_visible(player_pos: Vector2i, tile_pos: Vector2i) -> bool:
	var diff = tile_pos - player_pos
	return diff in offsets
