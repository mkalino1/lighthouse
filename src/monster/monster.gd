extends CharacterBody2D

enum MONSTER_TYPE {SHIPPER, HOUSER}

const MONSTER_DAMAGE = 10
const SPEED = 60.0
const HOUSER_COLOR = Color(0.849, 0.383, 0.241)
const HOUSER_PROBABILITY = 0.4

var monster_type
var ship
var push_back_mode = false
var push_back_direction = Vector2.ZERO
var is_dead = false

func _ready():
	monster_type = MONSTER_TYPE.SHIPPER if randf() > HOUSER_PROBABILITY else MONSTER_TYPE.HOUSER 
	match monster_type:
		MONSTER_TYPE.SHIPPER:
			find_closes_ship()
			$FindClosestShipTimer.start()
		MONSTER_TYPE.HOUSER:
			modulate = HOUSER_COLOR

func _process(delta):
	if rotation_degrees > 90 and rotation_degrees < 270:
		$Sprite2D.flip_v = true
	else:
		$Sprite2D.flip_v = false

func _physics_process(delta):
	if is_dead:
		return
	var destination = get_destination()
	if not destination:
		return
	look_at(destination)
	if not push_back_mode:
		velocity = global_position.direction_to(destination) * SPEED
	else:
		var time_left_percentage = $PushbackTimer.time_left / $PushbackTimer.wait_time
		velocity = push_back_direction * sin(time_left_percentage * PI * 0.5) * SPEED * 5
	var collision = move_and_collide(velocity * delta)
	if collision:
		var collider = collision.get_collider()
		if collider.is_in_group("ships"):
			get_parent().add_crash()
			collider.is_dead = true
			collider.queue_free()
			queue_free()
		if collider.is_in_group("lighthouse"):
			get_parent().change_lighthouse_hp(MONSTER_DAMAGE)
			queue_free()
		if collider.is_in_group("player"):
			is_dead = true
			queue_free()
			if (collider.player_is_dashing and collider.charge_ability) or collider.is_invincible:
				return
			get_parent().change_player_hp(MONSTER_DAMAGE)
			
				
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
	
func be_pushed_back(direction):
	push_back_mode = true
	push_back_direction = direction
	$PushbackTimer.start()

func _on_pushback_timer_timeout():
	push_back_mode = false
	push_back_direction = Vector2.ZERO

func find_closes_ship():
	var all_ships = get_tree().get_nodes_in_group("ships").filter(func(ship): return not ship.wrecked)
	var distance = 999999
	for tmp_ship in all_ships:
		var tmp_distance = position.distance_to(tmp_ship.position)
		if (tmp_distance < distance):
			distance = tmp_distance
			ship = tmp_ship
