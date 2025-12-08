extends Node2D

signal dice_rolled

@onready var villain: CharacterBody2D = $villain
@onready var player: CharacterBody2D = $player

@onready var enemy_sprite: AnimatedSprite2D = $villain/AnimatedSprite2D
@onready var player_sprite: AnimatedSprite2D = $player/AnimatedSprite2D

@onready var dice = $dice
@onready var player_hp_bar = $"player/Healthbar"
@onready var enemy_hp_bar = $"villain/Healthbar2"

var player_hp = 400
var enemy_hp = 400

var player_attack_value = 0
var enemy_attack_value = 0

enum State {PLAYER_ATTACK, ENEMY_ATTACK, CALCULATE}
var state = State.PLAYER_ATTACK

var player_won = false
var enemy_won = false

var game_over = false

func _ready() -> void:
	player_hp = 400
	enemy_hp = 400
	
	player_hp_bar.value = player_hp
	enemy_hp_bar.value = enemy_hp
	
	start_game()

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("dice roll"):
		emit_signal("dice_rolled")

func start_game():
	while not game_over:
		match state:
			State.PLAYER_ATTACK:
				await player_turn()
			State.ENEMY_ATTACK:
				await enemy_turn()
			State.CALCULATE:
				calculate_and_update_score(player_attack_value, enemy_attack_value)
	
	if game_over:
		if player_won:
			enemy_sprite.play("death")
		else:
			player_sprite.play("death")

func player_turn():
	if player_won or enemy_won:
		game_over = true
		return
	
	await dice_rolled
	var choice = await roll_dice()
	player_attack_value = calc_attack_amount(choice)
	await get_tree().create_timer(2.0).timeout
	state = State.ENEMY_ATTACK

func enemy_turn():
	var choice = await roll_dice()
	enemy_attack_value = calc_attack_amount(choice)
	state = State.CALCULATE

func calculate_and_update_score(player_attack_value, enemy_attack_value):
	var damage = abs(player_attack_value - enemy_attack_value)
	
	var weaker_attack = 0
	if player_attack_value != enemy_attack_value:
		weaker_attack = min(player_attack_value, enemy_attack_value)
		if weaker_attack == player_attack_value:
			villain.position.x -= 300
			enemy_sprite.play("attack")
			
			player_hp -= damage
			player_hp_bar.value = player_hp
			
			print("player remaining life: ", player_hp)
		elif weaker_attack == enemy_attack_value:
			enemy_hp -= damage
			enemy_hp_bar.value = enemy_hp
			
			print("remaining life of enemy: ", enemy_hp)
			
	
	if player_hp <= 0:
		enemy_won = true
	elif enemy_hp <= 0:
		player_won = true
	
	state = State.PLAYER_ATTACK

func roll_dice():
	var choices = [1, 2, 3, 4, 5, 6]
	var choice = choices.pick_random()
	print("dice roll " + str(choice))
	dice.play("dice roll " + str(choice))
	await dice.animation_finished
	return choice

func calc_attack_amount(choice):
	var damage_value_list = [0, 20, 50, 100, 150, 200]
	return damage_value_list[choice-1]
