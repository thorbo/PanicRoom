extends Node

@export var baby_scene: PackedScene
var MIN_LAUNCH_SPEED = 400
var MAX_LAUNCH_SPEED = 600
var MAX_LAUNCH_ANGLE = 80
var MIN_LAUNCH_ANGLE = 50
var MIN_UPGRADE_DELAY = 0.5
var MAX_UPGRADE_DELAY = 3
var CLEAN_LAUNCH_POSITION = 0.8
var LAUNCH_POSITIONS = [0.35, 0.5, 0.65]
var GAME_LENGTH = 60
var LAUNCH_INTERVAL_START = 3
var LAUNCH_INTERVAL_END = 0.5

var score
var baby_queue = []
var s_remaining

func start_game():
	# Clean up any babies on screen
	var all_babies = get_tree().get_nodes_in_group("babies")
	for baby in all_babies:
		baby.queue_free()
	
	$Background.set_frame(1)
	s_remaining = GAME_LENGTH
	score = 0
	$Trampoline.show()
	$Trampoline.process_mode = Node.PROCESS_MODE_INHERIT
	$HUD.show_game_hud()
	$StartButton.hide()
	$GameTicker.start()
	$LaunchTimer.set_wait_time(LAUNCH_INTERVAL_START)
	$LaunchTimer.start()
	$Music.play()
	
# Called when the node enters the scene tree for the first time.
func _ready():
	$Trampoline.hide()
	$StartButton.show()
	$HUD.show_start_menu(GAME_LENGTH)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if $StartButton.is_visible():
		if Input.is_action_pressed("start_game"):
			$StartButton.pressed.emit()
	
	
func make_baby(stage, clean_launch=false):
	# Conception
	var baby = baby_scene.instantiate()
	
	# set the baby start position
	var launch_spot : PathFollow2D = $LaunchPath/LaunchLocation
	launch_spot.progress_ratio = CLEAN_LAUNCH_POSITION if clean_launch else LAUNCH_POSITIONS[randi_range(0, len(LAUNCH_POSITIONS) - 1)]
	baby.position = launch_spot.position
	
	# give the baby some initial movement.
	# weirdly, this impulse is much higher than the one given to the bouncy 
	# trampoline yet it doesn't have near as much effect
	var angle = randi_range(MIN_LAUNCH_ANGLE, MAX_LAUNCH_ANGLE)
	angle = deg_to_rad(angle)
	var unit_vector = Vector2(cos(angle), -sin(angle))
	var speed = randi_range(MIN_LAUNCH_SPEED, MAX_LAUNCH_SPEED)
	var velocity = speed * unit_vector

	baby.set_linear_velocity(velocity)
	baby.set_angular_velocity(randf_range(-PI/2, PI/2))
	
	# connect signals here, since the child doesn't exist as a Node in the scene yet
	baby.connect("baby_safe", on_baby_saved)
	baby.connect("baby_dead", on_baby_dead)
	baby.connect("baby_back_to_hospital", on_baby_back_to_hospital)
	baby.set_stage(stage)
	return baby
	
	
func launch(baby):
	# HAPPY BIRTHDAY
	add_child(baby)


func on_baby_back_to_hospital(stage):
	var next_baby_stage = min(stage + 1, 2)
	baby_queue.push_front(make_baby(next_baby_stage))
	var baby_back_timer = get_tree().create_timer(randf_range(MIN_UPGRADE_DELAY, MAX_UPGRADE_DELAY))
	baby_back_timer.connect("timeout", on_baby_back_timer_timeout)
	
	
func on_baby_back_timer_timeout() :
	var baby = baby_queue.pop_back()
	launch(baby)
	
	
func on_baby_dead(stage):
	#TODO: FIGURE OUT CONSTANTS FILE TO SHARE THAT ENUM
	if stage == 0:
		update_score(-1)
	elif stage == 1:
		update_score(-3)
	elif stage == 2:
		pass
		
func on_baby_saved(stage):
	#TODO: FIGURE OUT CONSTANTS FILE TO SHARE THAT ENUM
	if stage == 0:
		update_score(1)
	elif stage == 1:
		update_score(5)
	elif stage == 2:
		update_score(-7)
	
func update_score(points):
	score += points
	$HUD/Score.text = str(score)

func _on_launch_timer_timeout():
	launch(make_baby(0)) 
	
func _on_game_ticker_timeout():
	# Update progress bar
	s_remaining -= 1
	$HUD/ProgressBar.set_value(s_remaining)
	if s_remaining == 0:
		end_game()
		
	# Speed up baby launcher
	var percent_played = (GAME_LENGTH - s_remaining) / float(GAME_LENGTH)
	var interpolated_launch_interval = LAUNCH_INTERVAL_START + percent_played * (LAUNCH_INTERVAL_END - LAUNCH_INTERVAL_START)
	var new_launch_interval = max(LAUNCH_INTERVAL_END, interpolated_launch_interval)
	$LaunchTimer.set_wait_time(new_launch_interval)

func _on_start_button_pressed():
	start_game()

func end_game():
	$Music.stop()
	$Background.set_frame(0)
	$Trampoline.hide()
	$Trampoline.process_mode = Node.PROCESS_MODE_DISABLED
	$HUD.show_start_menu(GAME_LENGTH, score)
	
	# Show start button after delay
	var show_start_button_timer = get_tree().create_timer(1.5)
	show_start_button_timer.connect("timeout", func():
		$StartButton.show()
	)
	
	# Stop showering babies after delay
	var turn_off_baby_hose = get_tree().create_timer(5)
	turn_off_baby_hose.connect("timeout", func():
		$LaunchTimer.stop()
	)
