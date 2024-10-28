extends CharacterBody2D

@export var bullet_scene: PackedScene

#PLAYER MOBILITY
const player_speed = 300
const player_dash_speed = 800
#BULLETS
const bullet_spped_initial = 800
const bullet_speed_increment = 400
const bullet_quantity_increment = 1

#Bullets
var bullet_cooldown_block = false
var bullet_speed = bullet_spped_initial
var bullet_quantity = 1
var back_bullet = false
#Player mobility
var player_is_dashing = false
var charge_ability = false

func _input(event):
	if event.is_action_pressed("shoot"):
		shoot()
	if event.is_action_pressed("dash") and not player_is_dashing:
		player_is_dashing = true
		$DashTimer.start()

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
		velocity = velocity.normalized()
		if player_is_dashing:
			velocity = velocity * player_dash_speed
		else:
			velocity = velocity * player_speed
		
	var collided = move_and_slide()
	if collided and charge_ability and player_is_dashing:
		var collision = get_last_slide_collision()
		var collider = collision.get_collider()
		if collider.is_in_group("monsters") or collider.is_in_group("ships"):
			collider.queue_free()
			get_parent().add_exp(20)

func shoot():
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

func _on_dash_timer_timeout():
	player_is_dashing = false
	
func increase_bullet_speed():
	bullet_speed += bullet_speed_increment
	
func increase_bullet_quantity():
	bullet_quantity += bullet_quantity_increment
	
func enable_charge_ability():
	charge_ability = true
