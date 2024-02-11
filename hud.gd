extends CanvasLayer

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func show_start_menu(game_length, score=null):
	$ProgressBar.hide()
	$ProgressBar.set_max(game_length)
	$ProgressBar.set_value(game_length)
	$Score.hide()
	$Title.show()
	if score:
		$GameEndScore.text = str(score)
		$GameEndScore.show()
	else:
		$GameEndScore.hide()

func show_game_hud():
	$ProgressBar.show()
	$Score.show()
	$Score.text = "0"
	$Title.hide()
	$GameEndScore.hide()
	
