extends Node2D
@onready var dice = $dice/dice_sprite
@onready var player_hp_bar = $"player/Healthbar"
@onready var enemy_hp_bar = $"villain/Healthbar2"

var player_hp = 400
var enemy_hp = 400

var player_turn = true

var player_attack
var enemy_attack

func _ready() -> void:
	print("Started Game")
	update_health_bars() 

var can_press = true
#var turn = true
func _process(delta: float) -> void:
	start_game()

func start_game():
	if player_turn and Input.is_action_just_pressed("dice roll") and can_press:
		can_press = false
		var player_choice = choose()
		await roll_dice(player_choice)
		player_attack = roll_conversion(player_choice)
		
		await get_tree().create_timer(1.0).timeout #wait for the enemy to roll so that animation doesnt get frame mixed
		
		var enemy_choice = choose()
		await roll_dice(enemy_choice)
		enemy_attack = roll_conversion(enemy_choice)
		
		if player_attack > enemy_attack:
			var damage = abs(player_attack - enemy_attack)
			enemy_hp -= damage
			update_health_bars()
		elif player_attack < enemy_attack:
			var damage = abs(player_attack - enemy_attack)
			player_hp -= damage
			update_health_bars()
		
		player_turn = !player_turn #swap turns
	
	if !player_turn:
		await get_tree().create_timer(1.0).timeout #wait for the enemy to roll so that animation doesnt get frame mixed
		var enemy_choice = choose()
		await roll_dice(enemy_choice)
		var enemy_attack = roll_conversion(enemy_choice)
		
		await get_tree().create_timer(1.0).timeout #now wait so player can roll
		can_press = true
		
		if Input.is_action_just_pressed("dice roll") and can_press:
			can_press = false
			var player_choice = choose()
			await roll_dice(player_choice)
			player_attack = roll_conversion(player_choice)
		
		if player_attack > enemy_attack:
			var damage = abs(player_attack - enemy_attack)
			enemy_hp -= damage
			update_health_bars()
		elif player_attack < enemy_attack:
			var damage = abs(player_attack - enemy_attack)
			player_hp -= damage
			update_health_bars()
		
		player_turn = !player_turn #swap turns

func choose() -> int:
	var choices = [1,2,3,4,5,6]
	return choices.pick_random()

func roll_conversion(dice_val):
	var converted_rolls = [0, 20, 50, 100, 150, 200]
	return converted_rolls[dice_val - 1]

func update_health_bars():
	player_hp_bar.value = player_hp
	enemy_hp_bar.value = enemy_hp

func check_game_over():
	if player_hp <= 0:
		print("Enemy wins!")
	elif enemy_hp <= 0:
		print("Player wins!")

func roll_dice(dice_val):
	dice.play("dice roll " + str(dice_val))
	await get_tree().create_timer(1.0).timeout
	dice.stop()
	dice.frame = dice.sprite_frames.get_frame_count("dice roll " + str(dice_val)) - 1
