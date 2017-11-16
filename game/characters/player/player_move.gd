extends Node2D
#quick access to constnats
onready var CONST = get_node("/root/const")

enum JUMP_STATES { WIND_UP = 0, ASCEND = 1, DESCEND = 2 }

#jump constants
const JUMP_STRENGTH = 250
const JUMP_WIND_UP = 0.1
const JUMP_ASCEND_TIME = 0.45
const MOVESPEED_X_JUMP = 75

var WALK_SPEED = Vector2(100, 50)
var RUN_SPEED = Vector2(175, 80)
#movement directions dictionary for looped movement processing
onready var MOVEMENT = {
	CONST.INPUT_ACTION_MOVE_LEFT: Vector2(-1.0, 0.0), 
	CONST.INPUT_ACTION_MOVE_RIGHT: Vector2(1.0, 0.0), 
	CONST.INPUT_ACTION_MOVE_UP: Vector2(0.0, -1.0), 
	CONST.INPUT_ACTION_MOVE_DOWN: Vector2(0.0, 1.0)
}
onready var parent = get_node("../")
onready var sprite = get_node("../sprites")
#access to attacks, to know when to lock
onready var attacks = get_node("../player_attack")


var jump_start_height = 0 #Y height to come back to after jump finished
var jump_state
var current_jump_wind_up = 0
var current_jump_ascend = 0

#is the character locked into this set of actions for now?
var locked = false

var last_action_up = {
	"time":0,
	"action": ""
}
var last_frame_action = ""

func _ready():
	parent.current_state = parent.STANDING
	set_process(true)

#custom callback, gets called when parent is ready
#useful when a wired parent is required
func _parent_ready():
	#setup jump length based on animations
	parent.anim.get_animation(CONST.PLAYER_ANIM_JUMP_START).set_length(JUMP_WIND_UP)
	parent.anim.get_animation(CONST.PLAYER_ANIM_JUMP_AIR).set_length(JUMP_ASCEND_TIME)

func _process(delta):
	
	#initial frame logic
	parent.move_vector = Vector2(0, 0)
	var frame_action = ""
	if (!attacks.locked or jump_state != null):
		for action in MOVEMENT:
			#movement not allowed when locked into attack, except when parent.JUMPING
			if (Input.is_action_pressed(action)):
				parent.move_vector += MOVEMENT[action]
				frame_action = action
	
	if (jump_state == null and !attacks.locked):
		#resolve parent.RUNNING state
		if (parent.current_state == parent.RUNNING):
			#control different when already parent.RUNNING
			if (!frame_action.empty() and frame_action != last_action_up.action):
				#pressed different direction, lets stop parent.RUNNING
				parent.current_state = parent.STANDING
		else:
			if (!frame_action.empty() and frame_action == last_action_up.action
				and OS.get_unix_time() - last_action_up.time <= CONST.DOUBLE_TAP_INTERVAL_MS):
					parent.current_state = parent.RUNNING
		#process deciding to jump
		var pressed_jump = Input.is_action_pressed(CONST.INPUT_ACTION_JUMP)
		if (pressed_jump):
			parent.current_state = parent.JUMPING
			frame_action = CONST.INPUT_ACTION_JUMP
			jump_state = JUMP_STATES.WIND_UP
			current_jump_wind_up = JUMP_WIND_UP
			parent.next_anim = CONST.PLAYER_ANIM_JUMP_START
			#cant switch to attack while jump-squatting
			locked = true
	else: 
		#process current jump state
		if (jump_state == JUMP_STATES.WIND_UP):
			current_jump_wind_up -= delta
			parent.move_vector.x = 0
			if (current_jump_wind_up <= 0):
				current_jump_wind_up = 0
				jump_state = JUMP_STATES.ASCEND
				parent.move_vector.y = -JUMP_STRENGTH
				parent.ignore_G = true
				current_jump_ascend = JUMP_ASCEND_TIME
				parent.feet_ground_y = parent.feet_pos.y
				#once jump is ascending, character can attack
				locked = false
		
		if (jump_state == JUMP_STATES.ASCEND):
			current_jump_ascend -= delta
			#stop moving up when ascend over
			if current_jump_ascend > 0:
				parent.move_vector.y = -JUMP_STRENGTH 
			#move on to descend after attack is finished
			if (current_jump_ascend <= 0 && !parent.current_state == parent.ATTACKING):
				current_jump_ascend = 0
				jump_state = JUMP_STATES.DESCEND
				#no need to move down with gravity
				#done in parent
				parent.ignore_G = false
				
		if (jump_state == JUMP_STATES.DESCEND):

			if (parent.feet_pos.y >= parent.feet_ground_y):
				parent.move_vector.y = parent.feet_pos.y - parent.feet_ground_y
				jump_state = null
				parent.feet_ground_y = null
				#stop descend attack if it was in progress
				if (parent.current_state == parent.ATTACKING):
					attacks.reset_attack_state()
			
		
	if (parent.move_vector.length_squared() != 0):
		# resolve movement speed based on character state
		if (jump_state != null):
			parent.move_vector.x *= MOVESPEED_X_JUMP
		elif (parent.current_state == parent.RUNNING):
			parent.move_vector *= RUN_SPEED
		else:
			parent.current_state = parent.WALKING
			parent.move_vector *= WALK_SPEED
			
	
		#setup movement animation
		if (parent.current_state == parent.JUMPING):
#			parent.next_anim = CONST.PLAYER_ANIM_JUMP_START
			pass
		elif (parent.current_state == parent.RUNNING):
			parent.next_anim = CONST.PLAYER_ANIM_RUN
		elif (parent.current_state == parent.WALKING):
			parent.next_anim = CONST.PLAYER_ANIM_WALK
		#flip sprite if direction change
		if (parent.move_vector.x < 0 and frame_action == CONST.INPUT_ACTION_MOVE_LEFT):
			sprite.set_scale(Vector2(-1.0, 1.0))
		elif (parent.move_vector.x > 0 and frame_action == CONST.INPUT_ACTION_MOVE_RIGHT):
			sprite.set_scale(Vector2(1.0, 1.0))
	else:
		#only apply idle animation if no other
		#animation was chosen as part of the logic
		if (parent.current_state != parent.ATTACKING and !attacks.locked and jump_state == null):
			parent.current_state = parent.STANDING
			parent.next_anim = CONST.PLAYER_ANIM_IDLE
	
	#clear animation state if attacking
	if (parent.current_state == parent.ATTACKING and attacks.locked):
		parent.next_anim = null
	
	#set up for next frame
	
	
	#if there was move input in last frame, lets record action release
	if (!last_frame_action.empty() and frame_action.empty()):
		last_action_up = {
			"time": OS.get_unix_time(),
			"action": last_frame_action
		}
	last_frame_action = frame_action