extends StaticBody2D

#BEAM
const beam_scale_increment = Vector2(0.4, 0.4)
#Rotation
const offcenter_angle_initial = 10
const offcenter_angle_max = 10
const offcenter_angle_min = 3
const angle_speed_increment = 1

@export var light_beam_scene: PackedScene

#Rotation
var angle_speed = 1
var is_rotation_direction_changed = false;
var is_rotation_direction_change_desired = false;
var rotation_change_slowdown = false
var offcenter_angle = offcenter_angle_initial
var inital_light_beam_position

func _ready():
	inital_light_beam_position = $RotationPoint/LightBeam.position;

func _input(event):
	if event is InputEventKey and event.pressed and event.is_action("change_rotation"):
		rotation_change_slowdown = true
		is_rotation_direction_change_desired = not is_rotation_direction_change_desired
		$RotationPoint/RotationChangeMid.start()
	if event is InputEventMouseButton:
		if event.pressed:
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				offcenter_angle = clamp(offcenter_angle + 1, offcenter_angle_min, offcenter_angle_max)
			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				offcenter_angle = clamp(offcenter_angle - 1, offcenter_angle_min, offcenter_angle_max)

func _on_rotation_change_mid_timeout():
	is_rotation_direction_changed = is_rotation_direction_change_desired
	$RotationPoint/RotationChangeFinish.start()
	
func _on_rotation_change_finish_timeout():
	rotation_change_slowdown = false

func _physics_process(delta):
	var direction = -1 if is_rotation_direction_changed else 1
	var penalty = 1
	if rotation_change_slowdown:
		var mid_timer_left = $RotationPoint/RotationChangeMid.time_left
		var finish_timer_left = $RotationPoint/RotationChangeFinish.time_left
		penalty = mid_timer_left if mid_timer_left != 0 else (1 - finish_timer_left)
	$RotationPoint/LightBeam.position = inital_light_beam_position * offcenter_angle/10
	#$RotationPoint/LightBeam.global_position = position.move_toward($RotationPoint.global_position, 1)
	$RotationPoint.rotation += angle_speed * delta * direction * penalty
	
#***UPGRADES***
func increase_beam_scale():
	$RotationPoint/LightBeam.increase_scale(beam_scale_increment)

func increase_angle_speed():
	angle_speed += angle_speed_increment
	
func add_second_beam():
	var second_beam = light_beam_scene.instantiate()
	second_beam.position = Vector2(-250, 0)
	$RotationPoint.add_child(second_beam)
