extends Area2D
#quick access to constnats
onready var CONST = get_node("/root/const")

const MOVESPEED_X_WALK = 100
const MOVESPEED_Y_WALK = 50
const MOVESPEED_X_RUN = 175
const MOVESPEED_Y_RUN = 80
var WALK_SPEED = Vector2(MOVESPEED_X_WALK, MOVESPEED_Y_WALK)
var RUN_SPEED = Vector2(MOVESPEED_X_RUN, MOVESPEED_Y_RUN)
#movmeent directions dictionary for looped movement processing
onready var MOVEMENT = {
	CONST.INPUT_ACTION_MOVE_LEFT: Vector2(-1.0, 0.0), 
	CONST.INPUT_ACTION_MOVE_RIGHT: Vector2(1.0, 0.0), 
	CONST.INPUT_ACTION_MOVE_UP: Vector2(0.0, -1.0), 
	CONST.INPUT_ACTION_MOVE_DOWN: Vector2(0.0, 1.0)
}

#quick access to animator
onready var anim = get_node("anim")
onready var sprites_attack = get_node("sprites_attack")
onready var sprites_move = get_node("sprites_move")

var curr_anim = ""
var current_sprite
var move_vector = Vector2(0, 0)
var running = false
var last_action_up = {
	"time":0,
	"action": ""
}
var last_frame_action = ""

func _fixed_process(delta):
	
	#initial frame logic
	var next_anim = CONST.PLAYER_ANIM_IDLE
	current_sprite = sprites_move
	var pos = get_pos()
	move_vector = Vector2(0, 0)
	var frame_action = ""
	for action in MOVEMENT:
		if (Input.is_action_pressed(action)):
			move_vector += MOVEMENT[action]
			frame_action = action
	
	#pick movement speed
	if (running):
		#control different when already running
		if (!frame_action.empty() and frame_action != last_action_up.action):
			#pressed different direction, lets stop running
			running = false
	else:
		if (!frame_action.empty() and frame_action == last_action_up.action
			and OS.get_unix_time() - last_action_up.time <= CONST.DOUBLE_TAP_INTERVAL):
				running = true
	
	if (running):
		move_vector *= RUN_SPEED
	else:
		move_vector *= WALK_SPEED
	
	#integrate new position
	set_pos(pos + (move_vector * delta))
	
	#setup movement animation
	if (move_vector.length_squared() != 0):
		if (running
			and !curr_anim == CONST.PLAYER_ANIM_RUN_CONTINUE):
			next_anim = CONST.PLAYER_ANIM_RUN_START
		else:
			next_anim = CONST.PLAYER_ANIM_WALK
		#flip sprite if direction change
		if (move_vector.x < 0 and frame_action == CONST.INPUT_ACTION_MOVE_LEFT):
			current_sprite.set_scale(Vector2(-1.0, 1.0))
		elif (move_vector.x > 0 and frame_action == CONST.INPUT_ACTION_MOVE_RIGHT):
			current_sprite.set_scale(Vector2(1.0, 1.0))
	

	if (curr_anim != next_anim):
		curr_anim = next_anim
		anim.play(curr_anim)
	
	#set up for next frame
	
	#if there was move input in last frame, lets record action release
	if (!last_frame_action.empty() and frame_action.empty()):
		last_action_up = {
			"time": OS.get_unix_time(),
			"action": last_frame_action
		}
	last_frame_action = frame_action

func _ready():
	set_fixed_process(true)
	pass


#func _on_anim_finished():
#	#slot in second runner animation after first one over
#	if (running 
#	and anim.get_current_animation() == CONST.PLAYER_ANIM_RUN_START):
#		anim.play(CONST.PLAYER_ANIM_RUN_CONTINUE)
#		curr_anim = CONST.PLAYER_ANIM_RUN_CONTINUE
