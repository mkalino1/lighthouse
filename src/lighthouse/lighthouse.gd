extends StaticBody2D

@export var light_beam_scene: PackedScene

const BEAM_SCALE_INCREMENT = 0.4
const ANGLE_SPEED_INCREMENT = 1
const OFFCENTER_ANGLE_INITIAL = 10
const OFFCENTER_ANGLE_MAX = 10
const OFFCENTER_ANGLE_MIN = 3

var angle_speed = 1
var is_rotation_direction_changed = false;
var is_rotation_direction_change_desired = false;
var rotation_change_slowdown = false
var offcenter_angle = OFFCENTER_ANGLE_INITIAL
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
				offcenter_angle = clamp(offcenter_angle + 1, OFFCENTER_ANGLE_MIN, OFFCENTER_ANGLE_MAX)
			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				offcenter_angle = clamp(offcenter_angle - 1, OFFCENTER_ANGLE_MIN, OFFCENTER_ANGLE_MAX)

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
	$RotationPoint.rotation += angle_speed * delta * direction * penalty
	
#***UPGRADES***
func increase_beam_scale():
	for child in $RotationPoint.get_children():
		if child.is_in_group('beams'):
			child.increase_scale(BEAM_SCALE_INCREMENT)

func increase_angle_speed():
	angle_speed += ANGLE_SPEED_INCREMENT
	
func add_second_beam():
	var second_beam = light_beam_scene.instantiate()
	var first_beam = $RotationPoint/LightBeam
	second_beam.position = -first_beam.position
	second_beam.scale = first_beam.scale
	$RotationPoint.add_child(second_beam)
