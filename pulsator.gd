extends Area2D

var is_cooldown = false

func _ready():
	pass # Replace with function body.

func _process(delta):
	$Label.text = str($CooldownTimer.time_left).substr(0, 3)

func _on_cooldown_timer_timeout():
	if not $TriggerRing.has_overlapping_bodies():
		is_cooldown = false
	else:
		pushback_monsters()

func _on_trigger_ring_body_entered(body):
	if not is_cooldown:
		pushback_monsters()
		
func pushback_monsters():
	is_cooldown = true
	var monsters = get_overlapping_bodies()
	for monster in monsters:
		var target = monster.position - position
		monster.position += target.normalized() * 100;
	$CooldownTimer.start()
