extends HBoxContainer

@export var heart_scene: PackedScene = preload("res://src/heart/heart.tscn")

func set_max_hearts(num):
	for child in get_children():
		child.queue_free()
	for i in range(num):
		var heart_instance = heart_scene.instantiate()
		add_child(heart_instance)
		
func add_max_heart():
	var heart_instance = heart_scene.instantiate()
	add_child(heart_instance)
	move_child(heart_instance, 0)

func set_current_hearts(num):
	var tmp = num
	for child in get_children():
		child.change_filling(tmp > 0)
		tmp -= 1
	
