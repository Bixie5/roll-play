extends CharacterBody2D

const SPEED = 150.0

var anim
var last_direction = Vector2.RIGHT
var moving = false

func _ready():
	anim = $AnimatedSprite2D
	anim.play("idle")  # Make sure this matches your animation name exactly

func _physics_process(delta):
	var input_vector = Vector2.ZERO

	if Input.is_action_pressed("ui_left"):
		input_vector.x -= 1
	if Input.is_action_pressed("ui_right"):
		input_vector.x += 1
	if Input.is_action_pressed("ui_up"):
		input_vector.y -= 1
	if Input.is_action_pressed("ui_down"):
		input_vector.y += 1

	input_vector = input_vector.normalized()

	if input_vector != Vector2.ZERO:
		velocity = input_vector * SPEED
		moving = true

		# Update last_direction.x ONLY if moving left or right
		if input_vector.x != 0:
			last_direction.x = input_vector.x
	else:
		velocity = Vector2.ZERO
		moving = false

	move_and_slide()

	_update_animation()

func _update_animation():
	if moving:
		anim.flip_h = last_direction.x < 0  # Keep facing direction from last horizontal input

		# Play "run" when moving left/right, "walk" when moving only vertically
		if abs(velocity.x) > 0:
			if anim.animation != "run":
				anim.play("run")
		else:
			# Moving vertically only
			if anim.animation != "walk":
				anim.play("walk")
	else:
		if anim.animation != "idle":
			anim.play("idle")
