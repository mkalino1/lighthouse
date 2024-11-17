extends Node

@export var ship_scene: PackedScene
@export var mutalisk_scene: PackedScene
@export var light_beam_scene: PackedScene
@export var pulsator_scene: PackedScene

const MAX_SHIP_INCREMENT = 1
const MAX_MONSTER_INCREMENT = 6
const SHIP_SPAWN_MODIFIER = 0.9
const MONSTER_SPAWN_MODIFIER = 0.8
const SHIP_SUCCESS_EXP = 300

var wind_direction: Vector2 = Vector2.UP
var exp = 0
var level = 1
var wave = 1
var wave_pause = false
var crashes = 0
var max_ship_count = 1
var max_monster_count = 8

func _ready():
	$HUD.set_max_hearts($Player.player_hp)
	$HUD.update_exp_label(exp, exp_per_level(level))

func restart_game():
	get_tree().call_group("ships", "kill")
	get_tree().call_group("monsters", "queue_free")
	get_tree().call_group("pulsators", "queue_free")
	get_tree().call_group("spawned_lanterns", "queue_free")
	get_tree().call_group("exp_coins", "queue_free")
	get_tree().call_group("bullets", "queue_free")
	
	exp = 0
	level = 1
	wave = 1
	wave_pause = false
	crashes = 0
	max_ship_count = 1
	max_monster_count = 8
	$Lighthouse.lighthouse_hp = 10
	$Player.player_hp = 3
	$Timers/ShipSpawnTimer.wait_time = 2
	$Timers/MutaliskSpawnTimer.wait_time = 1
	
	$HUD.update_lighthouse_hp_label($Lighthouse.lighthouse_hp)
	$HUD.update_current_hearts($Player.player_hp)
	$HUD.set_max_hearts($Player.player_hp)
	$HUD.update_ship_timeout_label($Timers/ShipSpawnTimer.wait_time)
	$HUD.update_level_label(level)
	$HUD.update_exp_label(exp, exp_per_level(level))
	$HUD.update_crashes_label(crashes)
	$HUD.update_wave_label(wave)

func change_lighthouse_hp(value, add = false):
	$Lighthouse.lighthouse_hp = $Lighthouse.lighthouse_hp + value if add else $Lighthouse.lighthouse_hp - value
	$HUD.update_lighthouse_hp_label($Lighthouse.lighthouse_hp)
	if $Lighthouse.lighthouse_hp <= 0:
		$HUD.show_game_over_screen()
		
func change_player_hp(value, add = false):
	$Player.player_hp = $Player.player_hp + value if add else $Player.player_hp - value
	$HUD.update_current_hearts($Player.player_hp)
	if $Player.player_hp <= 0:
		$HUD.show_game_over_screen()

func add_exp(exp_to_add):
	exp += exp_to_add
	if exp >= exp_per_level(level):
		exp -= exp_per_level(level)
		level += 1
		max_ship_count += MAX_SHIP_INCREMENT
		$Timers/ShipSpawnTimer.wait_time *= SHIP_SPAWN_MODIFIER
		$HUD.update_ship_timeout_label($Timers/ShipSpawnTimer.wait_time)
		$HUD.update_level_label(level)
		$HUD.show_upgrade_selection()
	$HUD.update_exp_label(exp, exp_per_level(level))
	
func exp_per_level(level):
	return (level * 200 + 600) * level * 1/2
	
func add_crash():
	crashes += 1
	$HUD.update_crashes_label(crashes)
	
func spawn_ship():
	if get_tree().get_nodes_in_group("ships").size() >= max_ship_count:
		return
	var ship = ship_scene.instantiate()
	var ship_spawn_location = $Paths/ShipSpawnPath/ShipSpawnLocation
	ship_spawn_location.progress_ratio = randf()
	var direction = ship_spawn_location.rotation + PI / 2
	ship.position = ship_spawn_location.position
	direction += randf_range(-PI / 16, PI / 16)
	ship.rotation = direction
	var velocity = Vector2(randf_range(50.0, 150.0), 0.0)
	#ship.linear_velocity = velocity.rotated(direction)
	add_child(ship)
	
func spawn_mutalisk():
	if wave_pause or get_tree().get_nodes_in_group("monsters").size() >= max_monster_count:
		return
	var mutalisk = mutalisk_scene.instantiate()
	var side = randi() % 2 == 0
	var mutalisk_spawn_location = $Paths/MutaliskSpawnPathLeft/MutaliskSpawnLocation if side else $Paths/MutaliskSpawnPathRight/MutaliskSpawnLocation
	mutalisk_spawn_location.progress_ratio = randf()
	mutalisk.position = mutalisk_spawn_location.global_position
	add_child(mutalisk)
	
func spawn_lantern(position):
	var lantern = light_beam_scene.instantiate()
	lantern.scale = Vector2(0.5, 0.5)
	lantern.position = position
	lantern.placed_on_ground = true
	lantern.add_to_group('spawned_lanterns')
	add_child(lantern)
	
func spawn_pulsator(position):
	var pulsator = pulsator_scene.instantiate()
	pulsator.position = position
	add_child(pulsator)
	
func _on_wind_change_timer_timeout():
	wind_direction = wind_direction.rotated(randf_range(-0.3, 0.3))

func _on_wave_timer_timeout():
	wave_pause = true
	$Timers/WavePauseTimer.start()

func _on_wave_pause_timer_timeout():
	wave_pause = false
	wave += 1
	$HUD.update_wave_label(wave)
	max_monster_count += MAX_MONSTER_INCREMENT
	$Timers/MutaliskSpawnTimer.wait_time *= MONSTER_SPAWN_MODIFIER
	$Timers/WaveTimer.start()

func _on_out_of_bounds_body_exited(body):
	if body.is_in_group('ships') and not body.is_dead:
		add_exp(SHIP_SUCCESS_EXP)
	body.queue_free()

func _on_out_of_bounds_area_exited(area):
	area.queue_free()
