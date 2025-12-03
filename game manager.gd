extends Node2D

@export var player : character
@export var bot : character
var current_char : character

var game_over : bool = false

func next_turn ():
	if game_over:
		return
		
	if current_char != null:
		current_char.end_turn()
		
	if current_char == bot or player == null:
		current_char = player
	else:
		current_char = bot
	
	
