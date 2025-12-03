extends Node2D

@onready var dice = $dice/dice_sprite
@onready var player_hp_bar = $"player/Healthbar"
@onready var enemy_hp_bar = $"villain/Healthbar2"

var can_press = true
var turn = true  # true = player's turn to attack
var player_roll_value = 0
var enemy_roll_value = 0

var player_hp = 400
var enemy_hp = 400

func _ready():
	print("started")
	update_health_bars()

func _process(delta: float) -> void:
	if can_press and turn and Input.is_action_just_pressed("dice roll"):
		can_press = false
		handle_turn()


func choose_roll() -> int:
	return randi_range(1, 6)

func roll_to_value(roll: int) -> int:
	var values = [0, 20, 50, 100, 150, 200]
	return values[roll - 1]

func update_health_bars():
	player_hp_bar.value = player_hp
	enemy_hp_bar.value = enemy_hp

func handle_turn():
	print("--- TURN STARTED ---")
	
	# Attacker
	var attacker_roll = choose_roll()
	print("Attacker rolled: ", attacker_roll)
	dice.play("dice roll " + str(attacker_roll))
	await get_tree().create_timer(1.0).timeout  # Or await dice.animation_finished
	dice.stop()
	dice.frame = dice.sprite_frames.get_frame_count("dice roll " + str(attacker_roll)) - 1
	
	await get_tree().create_timer(1.0).timeout  # to wait so that enemy can roll
	
	# Defender
	var defender_roll = choose_roll()
	print("Defender rolled: ", defender_roll)
	dice.play("dice roll " + str(defender_roll))
	await get_tree().create_timer(1.0).timeout
	dice.stop()
	dice.frame = dice.sprite_frames.get_frame_count("dice roll " + str(defender_roll)) - 1
	
	# Damage
	var attacker_value = roll_to_value(attacker_roll)
	var defender_value = roll_to_value(defender_roll)
	var damage = abs(attacker_value - defender_value)
	
	if attacker_value > defender_value:
		if turn: enemy_hp -= damage
		else: player_hp -= damage
	elif defender_value > attacker_value:
		if turn: player_hp -= damage
		else: enemy_hp -= damage
	
	print("Damage dealt: ", damage)

	update_health_bars()
	check_game_over()
	turn = !turn
	if !turn:
		await get_tree().create_timer(0.8).timeout
		await handle_turn()
	else:
		can_press = true  # Ensure input is re-enabled
	print("--- TURN ENDED ---")

	#update_health_bars()
	#check_game_over()
	#turn = !turn  # Switch roles

func check_game_over():
	if player_hp <= 0:
		print("Enemy wins!")
	elif enemy_hp <= 0:
		print("Player wins!")
