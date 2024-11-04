extends Area2D

@export var exp_coin_scene: PackedScene

var speed
var exp_for_killing_monster
var destination
var rock_piercing

func _ready():
	destination = get_local_mouse_position()

func _physics_process(delta):
	position += destination.normalized() * speed * delta

func _on_lifespan_timer_timeout():
	queue_free()

func _on_body_entered(body):
	if body is TileMap:
		if not rock_piercing:
			queue_free()
		#modulate = Color(0.849, 0.383, 0.241)
		#var clicked_cell = body.local_to_map(position)
		#var center_of_cell = body.map_to_local(clicked_cell)
		#bounce(center_of_cell)
	else:
		var exp_coin = exp_coin_scene.instantiate()
		exp_coin.position = body.position
		exp_coin.exp_for_killing_monster = exp_for_killing_monster
		get_parent().add_child(exp_coin)
		body.queue_free()
		queue_free()
	
#Work in progress
func bounce(center_of_cell):
	var bounce_angle = (center_of_cell - position).angle()
	if bounce_angle < PI/4 or bounce_angle > 7*PI/4 or (bounce_angle > 3*PI/4 and bounce_angle < 5*PI/4):
		destination = Vector2(-destination.x, destination.y)
	else:
		destination = Vector2(destination.x, -destination.y)
