extends Area2D

var exp_for_killing_monster

func _on_body_entered(body):
	get_parent().add_exp(exp_for_killing_monster)
	queue_free()

func _on_timer_timeout():
	queue_free()
