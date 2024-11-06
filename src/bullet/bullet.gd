extends CharacterBody2D

@export var exp_coin_scene: PackedScene

var speed
var exp_for_killing_monster
var destination
var rock_piercing
var bouncing

func _ready():
	destination = get_local_mouse_position()
	# Consider changing to test_only collide
	if rock_piercing:
		collision_mask = 4

func _physics_process(delta):
	var collision = move_and_collide(destination.normalized() * speed * delta)
	if collision:
		var collider = collision.get_collider()
		if collider is TileMap:
			if bouncing:
				bounce(collider, collision)
			else:
				queue_free()
		else:
			hit_monster(collider)

func bounce(collider, collision):
	var clicked_cell = collider.local_to_map(position) 
	var center_of_clicked_cell = collider.map_to_local(clicked_cell)
	var bounce_angle = (center_of_clicked_cell - collision.get_position()).angle()
	if (bounce_angle < PI/4 and bounce_angle > -1*PI/4) or bounce_angle > 3*PI/4 or bounce_angle < -3*PI/4:
		destination = Vector2(-destination.x, destination.y)
	else:
		destination = Vector2(destination.x, -destination.y)

func hit_monster(monster):
	var exp_coin = exp_coin_scene.instantiate()
	exp_coin.position = monster.position
	exp_coin.exp_for_killing_monster = exp_for_killing_monster
	get_parent().add_child(exp_coin)
	monster.queue_free()
	queue_free()

func _on_lifespan_timer_timeout():
	queue_free()
