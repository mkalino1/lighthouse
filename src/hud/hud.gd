extends CanvasLayer

enum PLANT_COMPONENT_TYPE {LANTERN, PULSATOR}

var component_planting_mode = false
var component_to_plant = null
var current_upgrades_choice

@onready var all_upgrades = [
	{
		'name': 'Increase beam scale',
		'function': get_node("../Lighthouse").increase_beam_scale,
		'reset': get_node("../Lighthouse").reset_beam_scale,
		'building': false,
		'onetime': false,
	},
	{
		'name': 'Increase angle speed',
		'function': get_node("../Lighthouse").increase_angle_speed,
		'reset': get_node("../Lighthouse").reset_angle_speed,
		'building': false,
		'onetime': false,
	},
	{
		'name': 'Increase bullet speed',
		'function': get_node("../Player").increase_bullet_speed,
		'reset': get_node("../Player").reset_bullet_speed,
		'building': false,
		'onetime': false,
	},
	{
		'name': 'Increase bullet quantity',
		'function': get_node("../Player").increase_bullet_quantity,
		'reset': get_node("../Player").reset_bullet_quantity,
		'building': false,
		'onetime': false,
	},
	{
		'name': 'Plant lantern',
		'function': enter_planting_mode(PLANT_COMPONENT_TYPE.LANTERN),
		'reset': null,
		'building': true,
		'onetime': false,
	},
	{
		'name': 'Plant pulsator',
		'function': enter_planting_mode(PLANT_COMPONENT_TYPE.PULSATOR),
		'reset': null,
		'building': true,
		'onetime': false,
	},
	{
		'name': 'Add second beam',
		'function': get_node("../Lighthouse").add_second_beam,
		'reset': get_node("../Lighthouse").reset_second_beam,
		'building': false,
		'onetime': true,
	},
	{
		'name': 'Add charge ability',
		'function': get_node("../Player").enable_charge_ability,
		'reset': get_node("../Player").reset_charge_ability,
		'building': false,
		'onetime': true,
	},
	{
		'name': 'Add rock piercing ability',
		'function': get_node("../Player").enable_rock_piercing,
		'reset': get_node("../Player").reset_rock_piercing,
		'building': false,
		'onetime': true,
	},
	{
		'name': 'Add bullet bouncing ability',
		'function': get_node("../Player").enable_bullet_bouncing,
		'reset': get_node("../Player").reset_bullet_bouncing,
		'building': false,
		'onetime': true,
	},
	{
		'name': 'Add back bullet ability',
		'function': get_node("../Player").enable_back_bullet,
		'reset': get_node("../Player").reset_back_bullet,
		'building': false,
		'onetime': true,
	},
]

@onready var all_available_upgrades = all_upgrades.duplicate(true)

func _ready():
	show_upgrade_selection()
	
func show_upgrade_selection():
	get_tree().paused = true
	all_available_upgrades.shuffle()
	current_upgrades_choice = all_available_upgrades.slice(0, 4)
	$UpgradeSelection/UpgradeOption1.text = current_upgrades_choice[0].name
	$UpgradeSelection/UpgradeOption2.text = current_upgrades_choice[1].name
	$UpgradeSelection/UpgradeOption3.text = current_upgrades_choice[2].name
	$UpgradeSelection/UpgradeOption4.text = current_upgrades_choice[3].name
	$UpgradeSelection.show()

func show_game_over_screen():
	get_tree().paused = true
	$GameOverLabel.show()

func update_lighthouse_hp_label(hp):
	$LighthouseHpLabel.text = 'HP: ' + str(hp) + '/' + str(10)

func update_current_hearts(hp):
	$HeartsContainer.set_current_hearts(hp)
	
func set_max_hearts(hearts_num):
	$HeartsContainer.set_max_hearts(hearts_num)

func update_exp_label(exp, exp_level):
	$ExpLabel.text = str(exp) + '/' + str(exp_level)

func update_level_label(level):
	$LevelLabel.text = 'Level: ' + str(level)

func update_crashes_label(crashes):
	$CrashesLabel.text = 'Lost ships: ' + str(crashes)

func update_ship_timeout_label(timeout):
	$ShipTimeoutLabel.text = 'Ship timeout: ' + str(snappedf(timeout, 0.01)) + 's'

func update_wave_label(wave_number):
	$WaveLabel.text = 'Wave: ' + str(wave_number)

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
		all_available_upgrades.remove_at(all_available_upgrades.find(upgrade))

func close_upgrade_selection():
	get_tree().paused = false
	$UpgradeSelection.hide()
	
func enter_planting_mode(component):
	return func ():
		component_planting_mode = true
		component_to_plant = component
		$UpgradeSelection.hide()
	
func _input(event):
	if component_planting_mode and event is InputEventMouseButton and is_on_tile_map():
		var global_click_position = get_global_click_position(event)
		match component_to_plant:
			PLANT_COMPONENT_TYPE.LANTERN:
				get_parent().spawn_lantern(global_click_position)
			PLANT_COMPONENT_TYPE.PULSATOR:
				get_parent().spawn_pulsator(global_click_position)
		component_planting_mode = false
		get_tree().paused = false

func get_global_click_position(event):
	var tile_map = get_node("../NavigationRegion/TileMap")
	return tile_map.get_local_mouse_position()

func is_on_tile_map():
	var tile_map = get_node("../NavigationRegion/TileMap")
	var clicked_cell = tile_map.local_to_map(tile_map.get_local_mouse_position())
	var data = tile_map.get_cell_source_id(0, clicked_cell)
	#var collidingWith = get_collision_pos()
		#var tile = get_node("../NavigationRegion2D/TileMap").get_cell_source_id(get_node("../NavigationRegion2D/TileMap").world_to_map(click_position))
	#var tile = get_node("../NavigationRegion2D/TileMap").get_cell_atlas_coords(0, click_position)
	return data != -1

func _on_new_game_button_button_up():
	$GameOverLabel.hide()
	get_parent().restart_game()
	for ability in all_upgrades:
		if ability.reset:
			ability.reset.call()
	get_tree().paused = false
	
