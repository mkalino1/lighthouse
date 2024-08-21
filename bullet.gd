extends Area2D

var speed
var target: Vector2

func _ready():
	target = get_local_mouse_position()

func _physics_process(delta):
	position += target.normalized() * speed * delta

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

func _on_lifespan_timer_timeout():
	queue_free()

func _on_body_entered(body):
	if body.is_in_group("monsters"):
		body.queue_free()
		queue_free()
