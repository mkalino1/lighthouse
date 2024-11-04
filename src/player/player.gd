extends CharacterBody2D

@export var bullet_scene: PackedScene

#PLAYER MOBILITY
const PLAYER_SPEED = 300
const PLAYER_DASH_SPEED = 800
const EXP_FOR_KILLING_MONSTER = 20
#BULLETS
const BULLET_SPPED_INITIAL = 800
const BULLET_SPEED_INCREMENT = 400
const BULLET_QUANTITY_INCREMENT = 1

#Bullets
var bullet_cooldown_block = false
var bullet_speed = BULLET_SPPED_INITIAL
var bullet_quantity = 1
var back_bullet = false
#Player mobility
var player_is_dashing = false
var charge_ability = false
var rock_piercing_ability = false

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
			velocity = velocity * PLAYER_DASH_SPEED
		else:
			velocity = velocity * PLAYER_SPEED
		
	var collided = move_and_slide()
	if collided and charge_ability and player_is_dashing:
		var collision = get_last_slide_collision()
		var collider = collision.get_collider()
		if collider.is_in_group("monsters") or collider.is_in_group("ships"):
			collider.queue_free()
			get_parent().add_exp(EXP_FOR_KILLING_MONSTER)

func shoot():
	if bullet_cooldown_block:
		return
	bullet_cooldown_block = true
	$BulletCooldownTimer.start()
	if back_bullet:
		get_parent().add_child(instantiate_bullet(true))
	for i in range(bullet_quantity):
		get_parent().add_child(instantiate_bullet())
		if i != bullet_quantity -1:
			$BulletsDelayTimer.start()
			await $BulletsDelayTimer.timeout

func instantiate_bullet(is_back_bullet = false):
	var bullet = bullet_scene.instantiate()
	bullet.exp_for_killing_monster = EXP_FOR_KILLING_MONSTER
	bullet.position = position
	bullet.speed = bullet_speed if not is_back_bullet else -bullet_speed
	bullet.rock_piercing = rock_piercing_ability
	return bullet

func _on_bullet_cooldown_timer_timeout():
	bullet_cooldown_block = false

func _on_dash_timer_timeout():
	player_is_dashing = false
	
func increase_bullet_speed():
	bullet_speed += BULLET_SPEED_INCREMENT
	
func increase_bullet_quantity():
	bullet_quantity += BULLET_QUANTITY_INCREMENT
	
func enable_charge_ability():
	charge_ability = true
	
func enable_rock_piercing():
	rock_piercing_ability = true
	
func enable_back_bullet():
	back_bullet = true
