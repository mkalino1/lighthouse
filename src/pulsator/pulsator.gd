extends Area2D

var is_cooldown = false

func _process(delta):
	if $CooldownTimer.time_left == 0:
		$Label.text = ''
	else:
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
		var direction = (monster.position - position).normalized()
		monster.be_pushed_back(direction)
	$CooldownTimer.start()
