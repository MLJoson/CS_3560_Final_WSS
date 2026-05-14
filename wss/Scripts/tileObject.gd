extends Sprite2D

# Signal sent when this tile is clicked
# It sends the tile's grid position to the map script
signal tile_clicked(tile_pos)

# Stores this tile's position in the map grid
var grid_pos: Vector2i

# Runs when the tile's button is pressed
# Sends this tile's grid position so the player can move to it
func _on_button_pressed():
	# Convert the tile's world position into grid coordinates
	grid_pos = Vector2i(position.x / 50, position.y / 50)
	
	# Tell the map script which tile was clicked
	emit_signal("tile_clicked", grid_pos)

# Changes whether this tile is visible and clickable
func set_visible_state(is_visible: bool):
	if is_visible:
		# Show the tile normally
		modulate = Color(1, 1, 1)
		
		# Allow the player to click this tile
		$Button.disabled = false
	else:
		# Darken the tile to show it is outside the player's vision
		modulate = Color(0.001, 0.001, 0.001)
		
		# Prevent the player from clicking this tile
		$Button.disabled = true
