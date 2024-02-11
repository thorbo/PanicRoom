extends RigidBody2D

@export var speed = 500
@export var bouncy_collision_box_h = 80
var y_start
var depression_speed = 200
var spring_up_speed = 400

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimatedSprite2D.set_frame(1)
	y_start = position.y


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Handle x movement
	var direction = 0
	if Input.is_action_pressed("paddle_left"):
		direction = -1
	elif Input.is_action_pressed("paddle_right"):
		direction = 1
	var velocity = direction * speed
	position.x = clamp(position.x + velocity * delta, 0, get_viewport().size.x)

	# Handle y movement
	if Input.is_action_pressed("paddle_down"):
		position.y = clamp(position.y + depression_speed * delta, y_start, get_viewport().size.y)
	else:
		position.y = clamp(position.y - spring_up_speed * delta, y_start, get_viewport().size.y)


func _on_body_entered(body):
	# Boing for babies
	$AnimatedSprite2D.play()
