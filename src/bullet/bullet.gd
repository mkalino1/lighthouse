extends Area2D

@export var exp_coin_scene: PackedScene

var speed
var target: Vector2
var exp_for_killing_monster

func _ready():
	target = get_local_mouse_position()

func _physics_process(delta):
	position += target.normalized() * speed * delta

func _on_lifespan_timer_timeout():
	queue_free()

func _on_body_entered(body):
	var exp_coin = exp_coin_scene.instantiate()
	exp_coin.position = body.position
	exp_coin.exp_for_killing_monster = exp_for_killing_monster
	get_parent().add_child(exp_coin)
	body.queue_free()
	queue_free()
