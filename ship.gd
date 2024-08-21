extends CharacterBody2D

const movement_speed: float = 150.0

var movement_target_position: Vector2 = Vector2.ZERO
var lighted = false
var wrecked = false

@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D

func _ready():
	# Make sure to not await during _ready.
	call_deferred("actor_setup")

func actor_setup():
	# Wait for the first physics frame so the NavigationServer can sync.
	await get_tree().physics_frame
	# Now that the navigation map is no longer empty, set the movement target.
	var ship_destination_location = get_node("../Paths/ShipDestinationPath/ShipDestinationLocation")
	ship_destination_location.progress_ratio = randf()
	navigation_agent.target_position = ship_destination_location.position

func _physics_process(delta):
	if wrecked:
		return
	var next_path_position: Vector2 = navigation_agent.get_next_path_position()
	if lighted:
		velocity = global_position.direction_to(next_path_position) * movement_speed
		#velocity = velocity.lerp(direction * speed, accel * delta)
	else:
		#var direction = global_position.direction_to(next_path_position) * 7 + get_parent().wind_direction * 3
		var direction = global_position.direction_to(next_path_position)
		velocity = direction.normalized() * movement_speed * 0.3
	var collided = move_and_slide()
	#if collided and not lighted:
		#$LightUpTimer.stop()
		#modulate = Color(0.849, 0.383, 0.241)
		#wrecked = true
		#lighted = false
		#get_parent().add_crash()
		#$CrashedTimer.start()

func light_entered():
	if wrecked:
		return
	$LightUpTimer.stop()
	modulate = Color(0.249, 0.883, 0.441)
	lighted = true
	
func light_exited():
	if wrecked:
		return
	$LightUpTimer.start()

func _on_light_up_timer_timeout():
	#modulate = Color(0.549, 0.583, 0.141)
	modulate = Color.WHITE
	lighted = false

func _on_visible_on_screen_notifier_2d_screen_exited():
	get_parent().add_exp(100)
	queue_free()

func _on_crashed_timer_timeout():
	queue_free()
