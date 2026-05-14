extends Camera2D

# How much the camera zoom changes with each mouse wheel scroll
# This is based on the camera's current zoom level
var zoomSpd: float = 0.05 * zoom.y

# The smallest zoom value allowed
# Lower values mean the camera can zoom farther out
var Minzoom: float = 0.1

# The largest zoom value allowed
# Higher values mean the camera can zoom farther in
var Maxzoom: float = 1.0

# Controls how sensitive right-click dragging is
var dragSen: float = 1.0

# Controls how strongly the camera moves toward or away from the mouse while zooming
var spd = zoomSpd * 3.5 * zoom.y * zoom.y 

func _input(event):
	# Get the mouse position in world coordinates
	var mouse_position = get_global_mouse_position()
	
	# Find the distance between the mouse and the camera's current position
	var mouse_delta = mouse_position - global_position

	# Move the camera when the right mouse button is held and the mouse moves
	# Dividing by zoom.y keeps dragging speed feeling consistent at different zoom levels
	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		position -= event.relative * (dragSen / zoom.y)

	# Handle mouse wheel input for zooming
	if event is InputEventMouseButton:
		# Zoom in when scrolling up, unless already at maximum zoom
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and zoom.y != Maxzoom:
			zoom += Vector2(zoomSpd, zoomSpd)
			
			# Move the camera slightly toward the mouse while zooming in
			position += mouse_delta * spd
		
		# Zoom out when scrolling down
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom -= Vector2(zoomSpd, zoomSpd)
			
			# Move the camera slightly away from the mouse while zooming out,
			# but only if still above the minimum zoom
			if zoom.y > Minzoom:
				position -= mouse_delta * spd 

		# Keep the zoom value between the min and max limits
		zoom = clamp(zoom, Vector2(Minzoom, Minzoom), Vector2(Maxzoom, Maxzoom))
