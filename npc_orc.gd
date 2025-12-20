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
	get_tree().change_scene_to_file("res://fight.tscn")
	dialogue_active = false
	$DialogueBubble.visible = false

@onready var orc: CharacterBody2D = $"."

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_nearby = true
		$DialogueBubble.visible = false
		dialogue_active = false  # Optional: reset on exit/enter

		if body.global_position.x < global_position.x:
			get_child(0).flip_h = true
			#scale.x = -1  # Face left
		else:
			#scale.x = 1   # Face right
			get_child(0).flip_h = false


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_nearby = false
		$DialogueBubble.visible = false
		dialogue_active = false
