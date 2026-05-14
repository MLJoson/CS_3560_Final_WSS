extends Sprite2D

signal tile_clicked(tile_pos)

var grid_pos: Vector2i

#gives the tile position to the player to move to
func _on_button_pressed():
	grid_pos = Vector2i(position.x / 50, position.y / 50)
	emit_signal("tile_clicked", grid_pos)

#making tiles visible under vision
func set_visible_state(is_visible: bool):
	if is_visible:
		modulate = Color(1,1,1) # normal
		$Button.disabled = false
	else:
		modulate = Color(0.001,0.001,0.001) # dark/clouded
		$Button.disabled = true
