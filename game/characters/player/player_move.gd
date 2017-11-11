extends Node2D
#quick access to constnats
onready var CONST = get_node("/root/const")

enum JUMP_STATES { WIND_UP = 0, ASCEND = 1, DESCEND = 2 }

#jump constants
const GRAVITY = Vector2(0.0, 198)
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
#access to attacks, to know when to lock
onready var attacks = get_node("../player_attack")

var move_vector = Vector2(0, 0)
var jump_start_height = 0 #Y height to come back to after jump finished
var jump_state
var current_jump_wind_up = 0
var current_jump_ascend = 0
var jump_ground
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
	var pos = parent.get_pos()
	move_vector = Vector2(0, 0)
	var frame_action = ""
	if (!attacks.locked or jump_state != null):
		for action in MOVEMENT:
			#movement not allowed when locked into attack, except when parent.JUMPING
			if (Input.is_action_pressed(action)):
				move_vector += MOVEMENT[action]
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
			move_vector.x = 0
			if (current_jump_wind_up <= 0):
				current_jump_wind_up = 0
				jump_state = JUMP_STATES.ASCEND
				move_vector.y = -JUMP_STRENGTH
				current_jump_ascend = JUMP_ASCEND_TIME
				jump_ground = pos.y
				#once jump is ascending, character can attack
				locked = false
		
		if (jump_state == JUMP_STATES.ASCEND):
			current_jump_ascend -= delta
			move_vector.y = -JUMP_STRENGTH if current_jump_ascend > 0 else GRAVITY.y
			#move on to descend after attack is finished
			if (current_jump_ascend <= 0 && !parent.current_state == parent.ATTACKING):
				current_jump_ascend = 0
				jump_state = JUMP_STATES.DESCEND
				move_vector.y = GRAVITY.y
				
		if (jump_state == JUMP_STATES.DESCEND):
			move_vector.y = GRAVITY.y 
			if (parent.current_state == parent.ATTACKING):
				move_vector.y /= 2
			if (pos.y >= jump_ground):
				move_vector.y = pos.y - jump_ground
				jump_state = null
				#stop descend attack if it was in progress
				if (parent.current_state == parent.ATTACKING):
					attacks.reset_attack_state()
			
		
	if (move_vector.length_squared() != 0):
		# resolve movement speed based on character state
		if (jump_state != null):
			move_vector.x *= MOVESPEED_X_JUMP
		elif (parent.current_state == parent.RUNNING):
			move_vector *= RUN_SPEED
		else:
			parent.current_state = parent.WALKING
			move_vector *= WALK_SPEED
			
		#integrate new position
		var new_pos = pos + (move_vector * delta)
		parent.set_pos(new_pos)
		#also add posirion to caugh enemy
		if (parent.caught_enemy != null):
			parent.caught_enemy.set_pos(new_pos)
	
		#setup movement animation
		if (parent.current_state == parent.JUMPING):
#			parent.next_anim = CONST.PLAYER_ANIM_JUMP_START
			pass
		elif (parent.current_state == parent.RUNNING):
			parent.next_anim = CONST.PLAYER_ANIM_RUN
		elif (parent.current_state == parent.WALKING):
			parent.next_anim = CONST.PLAYER_ANIM_WALK
		#flip sprite if direction change
		if (move_vector.x < 0 and frame_action == CONST.INPUT_ACTION_MOVE_LEFT):
			parent.set_scale(Vector2(-1.0, 1.0))
		elif (move_vector.x > 0 and frame_action == CONST.INPUT_ACTION_MOVE_RIGHT):
			parent.set_scale(Vector2(1.0, 1.0))
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