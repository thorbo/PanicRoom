extends RigidBody2D

signal baby_safe
signal baby_dead
signal baby_back_to_hospital

enum STAGES {NEWBORN, BABY, ZOMBIE} 

var current_stage = STAGES.NEWBORN
var tracking
var already_emitted

# Called when the node enters the scene tree for the first time.
func _ready():
	tracking = false
	already_emitted = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if tracking:
		_on_visible_on_screen_notifier_2d_screen_exited()


func set_stage(stage):
	current_stage = stage
	$AnimatedSprite2D.set_frame(current_stage)
	
	
func _on_visible_on_screen_notifier_2d_screen_exited():
	# baby off screen right
	if position.x > get_viewport().size.x:
		baby_safe.emit(current_stage)
		queue_free()
		
		# baby below screen
	elif position.y > get_viewport().size.y:
		baby_dead.emit(current_stage)
		queue_free()
		
		# baby off screen left
	elif position.x < 0:
		baby_back_to_hospital.emit(current_stage)
		queue_free()
		
	# sky baby, keep tracking its position in case it goes past = right or left bounds
	else:
		tracking = true


func _on_visible_on_screen_notifier_2d_screen_entered():
	tracking = false


func _on_body_entered(body):
	# Propagate zombies
	if body.is_in_group("babies") and body.current_stage == 2:
		set_stage(STAGES.ZOMBIE)
		
