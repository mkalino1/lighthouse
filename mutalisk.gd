extends CharacterBody2D

enum MONSTER_TYPE {SHIPPER, HOUSER}

const SPEED = 60.0

var monster_type
var ship

func _ready():
	monster_type = MONSTER_TYPE.values()[randi() % MONSTER_TYPE.size()]
	match monster_type:
		MONSTER_TYPE.SHIPPER:
			find_closes_ship()
			$FindClosestShipTimer.start()
		MONSTER_TYPE.HOUSER:
			modulate = Color(0.849, 0.383, 0.241)

func _process(delta):
	if rotation_degrees > 90 and rotation_degrees < 270:
		$Sprite2D.flip_v = true
	else:
		$Sprite2D.flip_v = false

func _physics_process(delta):
	var destination = get_destination()
	if not destination:
		return
	look_at(destination)
	velocity = global_position.direction_to(destination) * SPEED
	var collision = move_and_collide(velocity * delta)
	if collision:
		var collider = collision.get_collider()
		if collider.is_in_group("ships"):
			get_parent().add_crash()
			collider.queue_free()
			queue_free()
		if collider.is_in_group("lighthouse"):
			get_parent().change_hp()
			queue_free()
			
func get_destination():
	match monster_type:
		MONSTER_TYPE.SHIPPER:
			if not ship:
				return
			return ship.position
		MONSTER_TYPE.HOUSER:
			return get_parent().get_node("Lighthouse").position

func _on_find_closest_ship_timer_timeout():
	find_closes_ship()
	
func light_entered():
	pass
	
func light_exited():
	pass

func find_closes_ship():
	var all_ships = get_tree().get_nodes_in_group("ships").filter(func(ship): return not ship.wrecked)
	var distance = 999999
	for tmp_ship in all_ships:
		var tmp_distance = position.distance_to(tmp_ship.position)
		if (tmp_distance < distance):
			distance = tmp_distance
			ship = tmp_ship
