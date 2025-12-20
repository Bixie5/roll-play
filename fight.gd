extends Node2D

signal dice_rolled

@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var villain: CharacterBody2D = $villain
@onready var player: CharacterBody2D = $player

@onready var data_label: Label = $statusbar/data_label

@onready var enemy_sprite: AnimatedSprite2D = $villain/AnimatedSprite2D
@onready var player_sprite: AnimatedSprite2D = $player/AnimatedSprite2D

@onready var villain_score: Label = $villain_score
@onready var player_score: Label = $player_score

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

var choice = -1
var game_over = false

var counter = 0

var rng = RandomNumberGenerator.new()

func _ready() -> void:
	#rng.seed = Time.get_ticks_usec()
	rng.randomize()
	
	data_label.text = "                  STATS"
	
	player_hp = 400
	enemy_hp = 400
	
	player_hp_bar.value = player_hp
	enemy_hp_bar.value = enemy_hp
	
	player_score.text = "400/400"
	villain_score.text = "400/400"
	
	enemy_sprite.animation_finished.connect(_on_enemy_anim_finished)
	player_sprite.animation_finished.connect(_on_player_anim_finished)
	
	start_game()

func _on_enemy_anim_finished():
	if enemy_sprite.animation == "attack" or enemy_sprite.animation == "hurt":
		enemy_sprite.play("default")

func _on_player_anim_finished():
	if player_sprite.animation == "attack" or player_sprite.animation == "hurt":
		player_sprite.play("idle")

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
			data_label.text = "YOU WIN"
			data_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		else:
			player_sprite.play("death")
			data_label.text = "YOU DIED"
			data_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

func player_turn():
	if player_won or enemy_won:
		game_over = true
		return
	
	await dice_rolled
	choice = await roll_dice()
	player_attack_value = calc_attack_amount(choice)
	if counter%2 == 0:
		data_label.text = "You Rolled " + str(choice) + " → " + str(player_attack_value) + " atk\n"
	else:
		data_label.text = "You Rolled " + str(choice) + " → " + str(player_attack_value) + " def\n"
		
	await get_tree().create_timer(2.0).timeout
	
	state = State.ENEMY_ATTACK

func enemy_turn():
	var choice = await roll_dice()
	enemy_attack_value = calc_attack_amount(choice)
	
	if counter%2 == 0:
		data_label.text += "Enemy Rolled " + str(choice) + " → " + str(enemy_attack_value) + " def\n"
	else:
		data_label.text += "Enemy Rolled " + str(choice) + " → " + str(enemy_attack_value) + " atk\n"
	
	counter += 1
	state = State.CALCULATE

func calculate_and_update_score(player_attack_value, enemy_attack_value):
	var damage = abs(player_attack_value - enemy_attack_value)
	
	var weaker_attack = 0
	if player_attack_value != enemy_attack_value:
		weaker_attack = min(player_attack_value, enemy_attack_value)
		
		if weaker_attack == player_attack_value:
			enemy_sprite.play("attack")
			player_sprite.play("hurt")
			animation_player.play("villain_strike")
			data_label.text += "Player HP → " + str(player_hp) + "-" + str(damage) + " = " + str(player_hp - damage)
			player_hp -= damage
			player_hp_bar.value = player_hp
			player_score.text = str(player_hp) + "/400"
			
			#print("player remaining life: ", player_hp)
		elif weaker_attack == enemy_attack_value:
			data_label.text += "Enemy HP → " + str(enemy_hp) + "-" + str(damage) + " = " + str(enemy_hp - damage)
			enemy_hp -= damage
			enemy_hp_bar.value = enemy_hp
			villain_score.text = str(enemy_hp) + "/400"
			player_sprite.play("attack")
			enemy_sprite.play("hurt")
			animation_player.play("player_strike")
			
			#print("remaining life of enemy: ", enemy_hp)
	else:
		data_label.text += "CANCELLED OUT"
	
	if player_hp <= 0:
		player_score.text = "0/400"
		enemy_won = true
	elif enemy_hp <= 0:
		villain_score.text = "0/400"
		player_won = true
	
	state = State.PLAYER_ATTACK

func roll_dice():
	#var choices = [1, 2, 3, 4, 5, 6]
	var choice = rng.randi_range(1, 6)
	#print("dice roll " + str(choice))
	dice.play("dice roll " + str(choice))
	await dice.animation_finished
	return choice

func calc_attack_amount(choice):
	var damage_value_list = [0, 20, 50, 100, 150, 200]
	return damage_value_list[choice-1]
