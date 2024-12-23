extends Area2D

var placed_on_ground = false
var is_second = false

func increase_scale(increment):
	scale += Vector2(increment, increment)
	
func reset_scale():
	scale = Vector2.ONE
	
func _ready():
	if placed_on_ground:
		skew = 0

func _on_body_entered(body):
	body.light_entered()

func _on_body_exited(body):
	body.light_exited()
