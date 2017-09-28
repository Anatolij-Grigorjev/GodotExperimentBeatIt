extends Area2D
#quick access to constnats
onready var CONST = get_node("/root/const")

const MOVESPEED_X = 100
const MOVESPEED_Y = 50

#quick access to animator
onready var anim = get_node("anim")
onready var sprites_attack = get_node("sprites_attack")
onready var sprites_move = get_node("sprites_move")

var curr_anim = ""
var current_sprite

func _fixed_process(delta):
	
	var next_anim = CONST.PLAYER_ANIM_IDLE
	current_sprite = sprites_move
	#gather inputs
	var move_left = Input.is_action_pressed(CONST.INPUT_ACTION_MOVE_LEFT)
	var move_right = Input.is_action_pressed(CONST.INPUT_ACTION_MOVE_RIGHT)
	var move_up = Input.is_action_pressed(CONST.INPUT_ACTION_MOVE_UP)
	var move_down = Input.is_action_pressed(CONST.INPUT_ACTION_MOVE_DOWN)
	
	
	var pos = get_pos()
	var move_vector = Vector2()
	if (move_left):
		move_vector.x = -MOVESPEED_X
	if (move_right):
		move_vector.x = MOVESPEED_X
	if (move_up):
		move_vector.y = -MOVESPEED_Y
	if (move_down):
		move_vector.y = MOVESPEED_Y
	
	#integrate new position
	set_pos(pos + (move_vector * delta))
	
	#some movement involved
	if (move_vector.length_squared() != 0):
		next_anim = CONST.PLAYER_ANIM_WALK
		#flip sprite if direction change
		if (move_vector.x < 0 and move_left):
			current_sprite.set_scale(Vector2(-1.0, 1.0))
		elif (move_vector.x > 0 and move_right):
			current_sprite.set_scale(Vector2(1.0, 1.0))
	

	if (curr_anim != next_anim):
		curr_anim = next_anim
		anim.play(curr_anim)


func _ready():
	set_fixed_process(true)
	pass


