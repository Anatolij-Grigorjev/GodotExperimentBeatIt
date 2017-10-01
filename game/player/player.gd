extends Area2D
#quick access to constnats
onready var CONST = get_node("/root/const")

enum JUMP_STATES { WIND_UP = 0, ASCEND = 1, DESCEND = 2 }

#jump constants
const GRAVITY = Vector2(0.0, 98)
const JUMP_HEIGHT = 200
const JUMP_WIND_UP = 0.3
const JUMP_ASCEND_TIME = 0.5

const MOVESPEED_X_WALK = 100
const MOVESPEED_Y_WALK = 50
const MOVESPEED_X_RUN = 175
const MOVESPEED_Y_RUN = 80
const MOVESPEED_X_JUMP = 75

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
var jump_start_height = 0 #Y height to come back to after jump finished
var running = false
var jumping = false
var jump_state
var current_jump_wind_up = 0
var current_jump_ascend = 0
var jump_ground

var last_action_up = {
	"time":0,
	"action": ""
}
var last_frame_action = ""

func _fixed_process(delta):
	
	#initial frame logic
	var next_anim = null
	current_sprite = sprites_move
	var pos = get_pos()
	move_vector = Vector2(0, 0)
	var frame_action = ""
	for action in MOVEMENT:
		if (Input.is_action_pressed(action)):
			move_vector += MOVEMENT[action]
			frame_action = action
	
	if (!jumping):
		#resolve running state
		if (running):
			#control different when already running
			if (!frame_action.empty() and frame_action != last_action_up.action):
				#pressed different direction, lets stop running
				running = false
		else:
			if (!frame_action.empty() and frame_action == last_action_up.action
				and OS.get_unix_time() - last_action_up.time <= CONST.DOUBLE_TAP_INTERVAL_MS):
					running = true
		#process deciding to jump
		var pressed_jump = Input.is_action_pressed(CONST.INPUT_ACTION_JUMP)
		if (pressed_jump):
			jumping = true
			frame_action = CONST.INPUT_ACTION_JUMP
			jump_state = JUMP_STATES.WIND_UP
			current_jump_wind_up = JUMP_WIND_UP
			next_anim = CONST.PLAYER_ANIM_JUMP_START
	else: 
		#process current jump state
		if (jump_state == JUMP_STATES.WIND_UP):
			current_jump_wind_up -= delta
			move_vector.x = 0
			if (current_jump_wind_up <= 0):
				current_jump_wind_up = 0
				jump_state = JUMP_STATES.ASCEND
				move_vector.y = -JUMP_HEIGHT
				current_jump_ascend = JUMP_ASCEND_TIME
				jump_ground = pos.y
		
		if (jump_state == JUMP_STATES.ASCEND):
			current_jump_ascend -= delta
			move_vector.y = -JUMP_HEIGHT
			if (current_jump_ascend <= 0):
				current_jump_ascend = 0
				jump_state = JUMP_STATES.DESCEND
				move_vector.y = GRAVITY.y
				
		if (jump_state == JUMP_STATES.DESCEND):
			move_vector.y = GRAVITY.y
			if (pos.y >= jump_ground):
				move_vector.y = pos.y - jump_ground
				jump_state = null
				jumping = false
			
	# resolve movement speed based on character state
	if (jumping):
		move_vector.x *= MOVESPEED_X_JUMP
	elif (running):
		move_vector *= RUN_SPEED
	else:
		move_vector *= WALK_SPEED
		
	#integrate new position
	set_pos(pos + (move_vector * delta))
	
	#setup movement animation
	if (move_vector.length_squared() != 0):
		if (jumping):
			next_anim = CONST.PLAYER_ANIM_JUMP_START
		elif (running):
			next_anim = CONST.PLAYER_ANIM_RUN_START
		else:
			next_anim = CONST.PLAYER_ANIM_WALK
		#flip sprite if direction change
		if (move_vector.x < 0 and frame_action == CONST.INPUT_ACTION_MOVE_LEFT):
			current_sprite.set_scale(Vector2(-1.0, 1.0))
		elif (move_vector.x > 0 and frame_action == CONST.INPUT_ACTION_MOVE_RIGHT):
			current_sprite.set_scale(Vector2(1.0, 1.0))
	else:
		#only apply idle animation if no other
		#animation was chosen as past of the logic
		if (next_anim == null and not jumping):
			next_anim = CONST.PLAYER_ANIM_IDLE
	

	#only apply another naimation if its different and was changed
	if (curr_anim != next_anim and next_anim != null):
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
