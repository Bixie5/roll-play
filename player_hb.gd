extends CharacterBody2D

@onready var health_bar: TextureProgressBar = $HealthBar

var max_health := 400
var current_health := 400

func _ready():
	update_health_bar()

func take_damage(amount: int):
	current_health = max(current_health - amount, 0)
	update_health_bar()
	if current_health <= 0:
		die()

func heal(amount: int):
	current_health = min(current_health + amount, max_health)
	update_health_bar()

func update_health_bar():
	health_bar.value = current_health

func die():
	print("Character is dead")
	queue_free()  # or trigger animation
