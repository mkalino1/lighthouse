extends CanvasLayer

var lantern_picking_mode = false

func _ready():
	show_upgrade_selection()
	
func show_upgrade_selection():
	get_tree().paused = true
	$UpgradeSelection.show()

func show_game_over_screen():
	get_tree().paused = true
	$GameOverLabel.show()

func update_hp_label(hp):
	$HpLabel.text = 'HP: ' + str(hp) + '/' + str(30)

func update_exp_label(exp, exp_level):
	$ExpLabel.text = str(exp) + '/' + str(exp_level)
	
func update_level_label(level):
	$LevelLabel.text = 'Level: ' + str(level)
	
func update_crashes_label(crashes):
	$CrashesLabel.text = 'Crashes: ' + str(crashes)	
	
func update_ship_timeout_label(timeout):
	$ShipTimeoutLabel.text = 'Ship timeout: ' + str(snappedf(timeout, 0.01)) + 's'	

func _on_upgrade_option_1_button_up():
	get_node("../Lighthouse").increase_beam_scale()
	close_upgrade_selection()

func _on_upgrade_option_2_button_up():
	get_node("../Lighthouse").increase_angle_speed()
	close_upgrade_selection()

func _on_upgrade_option_3_button_up():
	lantern_picking_mode = true
	$UpgradeSelection.hide()

func _on_upgrade_option_4_button_up():
	get_node("../Lighthouse").increase_bullet_speed()
	close_upgrade_selection()

func _on_upgrade_option_5_button_up():
	get_node("../Lighthouse").increase_bullet_quantity()
	close_upgrade_selection()

func _on_upgrade_option_6_button_up():
	print("not implemented")
	close_upgrade_selection()
	
func close_upgrade_selection():
	get_tree().paused = false
	$UpgradeSelection.hide()

func _input(event):
	#local_click = get_viewport().canvas_transform.affine_inverse().xform(event.position)
	#var tile = get_node("../NavigationRegion2D/TileMap").get_cell_atlas_coords(0, event.position)
	#print(tile) event.local_postion
	if lantern_picking_mode and event is InputEventMouseButton and is_on_tile_map():
		#if not is_on_tile_map():
			#return
		get_parent().spawn_lantern(event.position)
		lantern_picking_mode = false
		get_tree().paused = false

func is_on_tile_map():
	var tile_map = get_node("../NavigationRegion/TileMap")
	var clicked_cell = tile_map.local_to_map(tile_map.get_local_mouse_position())
	var data = tile_map.get_cell_source_id(0, clicked_cell)
	#var collidingWith = get_collision_pos()
		#var tile = get_node("../NavigationRegion2D/TileMap").get_cell_source_id(get_node("../NavigationRegion2D/TileMap").world_to_map(click_position))
	#var tile = get_node("../NavigationRegion2D/TileMap").get_cell_atlas_coords(0, click_position)
	return data != -1
