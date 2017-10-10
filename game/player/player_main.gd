extends Area2D
#utility functions
onready var UTILS = get_node("/root/utils")
onready var CONST = get_node("/root/const")

var current_sprite
onready var movement = get_node("player_move")
onready var attacks = get_node("player_attack")
var move_extents = Vector2()
var attack_extents = Vector2()
var current_extents

export var feet_pos = Vector2()
export var min_pos = Vector2()
export var max_pos = Vector2()

var moving = true
var attacking = false

onready var MOVEMENT_COMMANDS = [ 
	CONST.INPUT_ACTION_MOVE_LEFT, 
	CONST.INPUT_ACTION_MOVE_RIGHT, 
	CONST.INPUT_ACTION_MOVE_UP, 
	CONST.INPUT_ACTION_MOVE_DOWN, 
	CONST.INPUT_ACTION_JUMP
]
onready var ATTACK_COMMANDS = [
	CONST.INPUT_ACTION_ATTACK
]

func _ready():
	move_extents = UTILS.get_sprite_extents(movement.sprite)
	attack_extents = UTILS.get_sprite_extents(attacks.sprite)
	current_extents = move_extents
	switch_mode(attacking)
	set_process(true)

func _process(delta):
	
	#switch character mode based on input
	if (moving and !movement.locked):
		for action in ATTACK_COMMANDS:
			if (Input.is_action_pressed(action)):
				switch_mode(true)
	elif (attacking and !attacks.locked):
		for action in MOVEMENT_COMMANDS:
			if (Input.is_action_pressed(action)):
				switch_mode(false)
				
	
	var pos = get_pos()
	feet_pos = Vector2(pos.x, pos.y + current_extents.y)
	min_pos = Vector2(pos.x - current_extents.x, pos.y + current_extents.y)
	max_pos = Vector2(pos.x + current_extents.x, pos.y - current_extents.y)

func set_pos_by_feet(feet_pos):
	var pos = Vector2(feet_pos.x, feet_pos.y - current_extents.y)
	set_pos(pos)

func set_pos_by_min(min_pos):
	var pos = Vector2(min_pos.x + current_extents.x, min_pos.y - current_extents.y)
	set_pos(pos)

func set_pos_by_max(max_pos):
	var pos = Vector2(max_pos.x - current_extents.x, max_pos.y + current_extents.y)
	set_pos(pos)
	
func switch_mode(to_attacking):
	if (to_attacking):
		current_extents = attack_extents
		attacks.show()
		movement.hide()
	else: 
		current_extents = move_extents
		attacks.hide()
		movement.show()
	attacking = to_attacking
	moving = !to_attacking