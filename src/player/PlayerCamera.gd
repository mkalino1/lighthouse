extends Camera2D

@export var shake_strength_max = 13.0
@export var shake_fade = 8

var shake_strength = 0.0

var RNG = RandomNumberGenerator.new()

func _process(delta):
	if shake_strength > 0:
		shake_strength = lerp(shake_strength, 0.0, shake_fade * delta)
		offset = random_offset()

func shake_camera():
	shake_strength = shake_strength_max
	
func random_offset():
	return Vector2(RNG.randf_range(-shake_strength, shake_strength), RNG.randf_range(-shake_strength, shake_strength))
