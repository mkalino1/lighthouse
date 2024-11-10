extends CharacterBody2D

const MOVEMENT_SPEED = 150.0
const SHIP_LIGHTENED_COLOR = Color(0.249, 0.883, 0.441)
const NON_LIGHTENED_MODIFIER = 0.3

var movement_target_position = Vector2.ZERO
var lighted = false
var wrecked = false
var is_dead = false

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
		velocity = global_position.direction_to(next_path_position) * MOVEMENT_SPEED
	else:
		var direction = global_position.direction_to(next_path_position)
		velocity = direction.normalized() * MOVEMENT_SPEED * NON_LIGHTENED_MODIFIER
	var collided = move_and_slide()

func light_entered():
	if wrecked:
		return
	$LightUpTimer.stop()
	modulate = SHIP_LIGHTENED_COLOR
	lighted = true
	
func light_exited():
	if wrecked:
		return
	$LightUpTimer.start()

func _on_light_up_timer_timeout():
	modulate = Color.WHITE
	lighted = false

func _on_crashed_timer_timeout():
	queue_free()
