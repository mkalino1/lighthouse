extends CharacterBody2D

@export var bullet_scene: PackedScene

#PLAYER
const player_speed = 300.0
#BULLETS
const bullet_spped_initial = 800
const bullet_speed_increment = 200
const bullet_quantity_increment = 1

#Bullets
var bullet_cooldown_block = false
var bullet_speed = bullet_spped_initial
var bullet_quantity = 1
var back_bullet = false

func _input(event):
	if event is InputEventMouseButton:
		if event.pressed and event.is_action("shoot"):
			shoot()

func _physics_process(delta):
	velocity = Vector2.ZERO # The player's movement vector.
	if Input.is_action_pressed("go_right"):
		velocity.x += 1
	if Input.is_action_pressed("go_left"):
		velocity.x -= 1
	if Input.is_action_pressed("go_down"):
		velocity.y += 1
	if Input.is_action_pressed("go_up"):
		velocity.y -= 1
	
	if velocity.length() > 0:
		velocity = velocity.normalized() * player_speed
		
	move_and_slide()

func shoot():
	print("trying to shoot")
	if bullet_cooldown_block:
		return
	bullet_cooldown_block = true
	$BulletCooldownTimer.start()
	if back_bullet:
		var bullet = bullet_scene.instantiate()
		bullet.position = position
		bullet.speed = -bullet_speed
		get_parent().add_child(bullet)
	for i in range(bullet_quantity):
		var bullet = bullet_scene.instantiate()
		bullet.position = position
		bullet.speed = bullet_speed
		get_parent().add_child(bullet)
		if i != bullet_quantity -1:
			$BulletsDelayTimer.start()
			await $BulletsDelayTimer.timeout
			
func _on_bullet_cooldown_timer_timeout():
	bullet_cooldown_block = false

func increase_bullet_speed():
	bullet_speed += bullet_speed_increment
	
func increase_bullet_quantity():
	bullet_quantity += bullet_quantity_increment
