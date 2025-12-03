extends CharacterBody2D

# Set this to true when the player is near the NPC
var player_nearby: bool = false

# Sample dialogue lines
var dialogues := [
	"Hello, traveler.",
	"The forest is full of secrets.",
	"Come back if you seek guidance."
]

var current_line := 0
var dialogue_active := false

func _ready():
	# Hide the dialogue bubble at start
	$DialogueBubble.visible = false

func _process(_delta):
	# When player is near and presses E (interact)
	if player_nearby and Input.is_action_just_pressed("interact"):
		if not dialogue_active:
			start_dialogue()
		else:
			show_next_dialogue()


func start_dialogue():
	dialogue_active = true
	current_line = 0
	$DialogueBubble.visible = true
	$DialogueBubble/Label.text = dialogues[current_line]
	current_line += 1


func show_next_dialogue():
	if current_line >= dialogues.size():
		end_dialogue()
	else:
		$DialogueBubble/Label.text = dialogues[current_line]
		current_line = (current_line + 1)


func end_dialogue():
	dialogue_active = false
	$DialogueBubble.visible = false


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_nearby = true
		$DialogueBubble.visible = false
		dialogue_active = false  # Optional: reset on exit/enter


# Flip entire orc to face player
		if body.global_position.x < global_position.x:
			scale.x = -1  # Face left
		else:
			scale.x = 1   # Face right


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_nearby = false
		$DialogueBubble.visible = false
		dialogue_active = false
