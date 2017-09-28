extends Area2D
#quick access to constnats
onready var CONST = get_node("/root/const")

const MOVESPEED_X_WALK = 100
const MOVESPEED_Y_WALK = 50
var WALK_SPEED = Vector2(MOVESPEED_X_WALK, MOVESPEED_Y_WALK)


#quick access to animator
onready var anim = get_node("anim")
onready var sprites_attack = get_node("sprites_attack")
onready var sprites_move = get_node("sprites_move")

var curr_anim = ""
var current_sprite
var move_vector = Vector2()
var running = false
var last_movement_tap

func _fixed_process(delta):
	
	#initial frame logic
	var next_anim = CONST.PLAYER_ANIM_IDLE
	current_sprite = sprites_move
	var pos = get_pos()
	move_vector = Vector2()
	#gather inputs
	var move_left = Input.is_action_pressed(CONST.INPUT_ACTION_MOVE_LEFT)
	var move_right = Input.is_action_pressed(CONST.INPUT_ACTION_MOVE_RIGHT)
	var move_up = Input.is_action_pressed(CONST.INPUT_ACTION_MOVE_UP)
	var move_down = Input.is_action_pressed(CONST.INPUT_ACTION_MOVE_DOWN)
	
	
	if (move_left):
		move_vector.x = -1
	if (move_right):
		move_vector.x = 1
	if (move_up):
		move_vector.y = -1
	if (move_down):
		move_vector.y = 1
	
	#pick movement speed
	move_vector *= WALK_SPEED
	
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
	
	#set up for next frame
	
	#if there was move input in this frame, lets record when and to where
	if (move_vector.length_squared() > 0):
		last_movement_tap = {
			"time": OS.get_unix_time(),
			"direction": move_vector.normalized()
		}

func _ready():
	set_fixed_process(true)
	pass


