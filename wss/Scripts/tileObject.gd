extends Sprite2D

signal tile_clicked(tile_pos)

func _on_button_pressed():
	var grid_pos = Vector2i(position.x / 50, position.y / 50)
	emit_signal("tile_clicked", grid_pos)
