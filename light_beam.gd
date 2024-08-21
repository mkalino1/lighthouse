extends Area2D

var placed_on_ground = false

func increase_scale(increment):
	scale += increment
	
func _ready():
	if placed_on_ground:
		skew = 0

func _on_body_entered(body):
	body.light_entered()

func _on_body_exited(body):
	body.light_exited()

#func _process(delta):
	#if grounded:
		#return
	#var movement_vector = get_viewport().get_mouse_position() - position # getting the vector from self to the mouse
	#movement_vector = movement_vector.normalized() * delta * speed # normalize it and multiply by time and speed
	#position += movement_vector # move by that vector

	
#func _input(event):
	#if event is InputEventMouseButton:
		#print("Mouse Click/Unclick at: ", event.position)
	#elif event is InputEventMouseMotion:
		#var mouse_position = event.position
		
	
   # Print the size of the viewport.
	#print("Viewport Resolution is: ", get_viewport().get_visible_rect().size)

#func _process(delta):
	#var mouse_position = get_local_mouse_position()
	#position = mouse_position
	##rotation+= mousepositoion.angle() * 0.1
