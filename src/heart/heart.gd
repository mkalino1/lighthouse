extends Panel

func change_filling(fill):
	if fill:
		$Sprite2D.frame = 4
	else:
		$Sprite2D.frame = 0
