extends Camera2D


var zoomSpd: float = 0.05*zoom.y
var Minzoom: float = 0.1
var Maxzoom: float = 1.0
var dragSen: float = 1.0
var spd = zoomSpd*3.5*zoom.y*zoom.y 



func _input(event):
	var mouse_position = get_global_mouse_position()
	var mouse_delta = mouse_position - global_position

	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		position -= event.relative * (dragSen/zoom.y)

	if event is InputEventMouseButton: #for zooming
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and zoom.y!=Maxzoom:
			zoom += Vector2(zoomSpd,zoomSpd)
			position += mouse_delta * spd
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom -= Vector2(zoomSpd,zoomSpd)
			if zoom.y>Minzoom:
				position -= mouse_delta * spd 

		zoom = clamp(zoom, Vector2(Minzoom, Minzoom), Vector2(Maxzoom, Maxzoom)) #Limits the zooming
