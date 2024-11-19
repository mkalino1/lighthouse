extends PanelContainer

signal upgrade_clicked

func set_text(upgrade):
	$Button/VBoxContainer/Name.text = upgrade.name
	$Button/VBoxContainer/Description.text = upgrade.desc

func _on_button_button_up():
	upgrade_clicked.emit()
