extends CanvasLayer

var lantern_picking_mode = false

var current_upgrades_choice

@onready var all_upgrades = [
	{
		'name': 'Increase beam scale',
		'function': get_node("../Lighthouse").increase_beam_scale,
		'building': false,
		'onetime': false,
	},
	{
		'name': 'Increase angle speed',
		'function': get_node("../Lighthouse").increase_angle_speed,
		'building': false,
		'onetime': false,
	},
	{
		'name': 'Increase bullet speed',
		'function': get_node("../Lighthouse").increase_bullet_speed,
		'building': false,
		'onetime': false,
	},
	{
		'name': 'Increase bullet quantity',
		'function': get_node("../Lighthouse").increase_bullet_quantity,
		'building': false,
		'onetime': false,
	},
	{
		'name': 'Plant lantern',
		'function': enter_lantern_picking_mode,
		'building': true,
		'onetime': false,
	},
	{
		'name': 'Add second beam',
		'function': get_node("../Lighthouse").add_second_beam,
		'building': false,
		'onetime': true,
	},
]

func _ready():
	show_upgrade_selection()
	
func show_upgrade_selection():
	get_tree().paused = true
	all_upgrades.shuffle()
	current_upgrades_choice = all_upgrades.slice(0, 4)
	$UpgradeSelection/UpgradeOption1.text = current_upgrades_choice[0].name
	$UpgradeSelection/UpgradeOption2.text = current_upgrades_choice[1].name
	$UpgradeSelection/UpgradeOption3.text = current_upgrades_choice[2].name
	$UpgradeSelection/UpgradeOption4.text = current_upgrades_choice[3].name
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

#UPGRADES
func _on_upgrade_option_1_button_up():
	handle_upgrade_click(0)

func _on_upgrade_option_2_button_up():
	handle_upgrade_click(1)

func _on_upgrade_option_3_button_up():
	handle_upgrade_click(2)

func _on_upgrade_option_4_button_up():
	handle_upgrade_click(3)
	
func handle_upgrade_click(index):
	var upgrade = current_upgrades_choice[index]
	upgrade.function.call()
	if not upgrade.building:
		close_upgrade_selection()
	if upgrade.onetime:
		all_upgrades.remove_at(all_upgrades.find(upgrade))

func close_upgrade_selection():
	get_tree().paused = false
	$UpgradeSelection.hide()

func enter_lantern_picking_mode():
	lantern_picking_mode = true
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
