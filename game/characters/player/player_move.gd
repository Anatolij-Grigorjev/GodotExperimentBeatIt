extends Node2D
#quick access to constnats
onready var CONST = get_node("/root/const")
onready var UTILS = get_node("/root/utils")

enum JUMP_STATES { WIND_UP = 0, ASCEND = 1, DESCEND = 2 }

#jump constants
const JUMP_STRENGTH = 300
const JUMP_WIND_UP = 0.1
const JUMP_ASCEND_TIME = 0.35
const MOVESPEED_X_JUMP = 75

const INITIAL_JUMP_VALS = {
	"jump_state" : JUMP_STATES.WIND_UP,
	"current_jump_wind_up": JUMP_WIND_UP,
	"current_jump_ascend": JUMP_ASCEND_TIME
}

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

#states that dont allow this script to defualt to STANDING
#when no movement is happening
onready var NON_RESET_STATES = [
	parent.ATTACKING,
	parent.JUMPING,
	parent.JUMP_ATTACK,
	parent.CATCHING,
	parent.CATCH_ATTACKING,
	parent.HURTING,
	parent.FALLING,
	parent.FALLEN,
	parent.DYING
]
#states that ignore the movement input in this script (in some cases they register movement on thier own)
onready var NON_MOVE_STATES = [
	parent.ATTACKING,
	parent.CATCHING,
	parent.CATCH_ATTACKING,
]

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
	
func init_jump_state():
	parent.current_state_ctx["move_factor"] = (RUN_SPEED.x / WALK_SPEED.x) if parent.current_state == parent.RUNNING else 1.0
	parent.current_state = parent.JUMPING
	parent.next_anim = CONST.PLAYER_ANIM_JUMP_START
	for ctx_key in INITIAL_JUMP_VALS:
		parent.current_state_ctx[ctx_key] = INITIAL_JUMP_VALS[ctx_key]

func finish_jump_state():
	#Godot "feature" : dictionary erase method only works on local script dictionaries
	#if you want to erase keys from a dictionary in another script, make a local copy and reassign later
	#adding more keys doesnt have this problem
	var copy_dic = parent.current_state_ctx
	for ctx_key in INITIAL_JUMP_VALS:
		copy_dic.erase(ctx_key)
	copy_dic.erase("move_factor")
	parent.current_state_ctx = copy_dic


func _process(delta):
	#initial frame logic
	parent.move_vector = CONST.VECTOR2_ZERO
	#movement inputs ignored while hurting
	if (parent.current_state in parent.INDISPOSED_STATES):
		return
	var frame_action = ""
	if (not (parent.current_state in NON_MOVE_STATES )):
		for action in MOVEMENT:
			if (Input.is_action_pressed(action)):
				parent.move_vector += MOVEMENT[action]
				frame_action = action
	
	if (not (parent.current_state in parent.JUMPING_STATES)):
		#resolve running states
		if (parent.current_state == parent.RUNNING):
			#control different when already parent.RUNNING
			if (!frame_action.empty() and frame_action != last_action_up.action):
				#pressed different direction, lets stop parent.RUNNING
				parent.current_state = parent.STANDING
		elif (parent.current_state == parent.WALKING):
			if (!frame_action.empty() and frame_action == last_action_up.action
				and parent.timer - last_action_up.time <= CONST.DOUBLE_TAP_INTERVAL_SEC):
					parent.current_state = parent.RUNNING
		#process deciding to jump
		var pressed_jump = Input.is_action_pressed(CONST.INPUT_ACTION_JUMP) and not (parent.current_state in NON_MOVE_STATES)
		if (pressed_jump):
			init_jump_state()
			frame_action = CONST.INPUT_ACTION_JUMP
	else: 
		var jump_state = parent.current_state_ctx.jump_state
		#process current jump state
		if (jump_state == JUMP_STATES.WIND_UP):
			parent.current_state_ctx.current_jump_wind_up -= delta
			parent.move_vector.x = 0
			if (parent.current_state_ctx.current_jump_wind_up <= 0):
				parent.current_state_ctx.current_jump_wind_up = 0
				parent.current_state_ctx.jump_state = JUMP_STATES.ASCEND
				parent.move_vector.y = -(JUMP_STRENGTH * parent.current_state_ctx.move_factor)
				parent.ignore_G = true
				parent.current_state_ctx.current_jump_ascend = JUMP_ASCEND_TIME
				parent.feet_ground_y = parent.feet_pos.y

		if (jump_state == JUMP_STATES.ASCEND):
			parent.current_state_ctx.current_jump_ascend -= delta
			#stop moving up when ascend over
			if parent.current_state_ctx.current_jump_ascend > 0:
				parent.move_vector.y = -(JUMP_STRENGTH * parent.current_state_ctx.move_factor)
			#move on to descend after attack is finished
			if (parent.current_state_ctx.current_jump_ascend <= 0 and parent.current_state != parent.JUMP_ATTACK):
				parent.current_state_ctx.current_jump_ascend = 0
				parent.current_state_ctx.jump_state = JUMP_STATES.DESCEND
				#re-engage gravity, done ascending portion of jump
				parent.ignore_G = false
				
		if (jump_state == JUMP_STATES.DESCEND):
			if (parent.feet_pos.y >= parent.feet_ground_y):
				parent.move_vector.y = parent.feet_pos.y - parent.feet_ground_y
				finish_jump_state()
				#have to manually set it back to not ignore (set automatically when character in air)
				parent.ignore_z = false
				parent.feet_ground_y = null
				#stop descend attack if it was in progress
				if (parent.current_state == parent.JUMP_ATTACK):
					attacks.reset_attack_state()
				else:
					parent.current_state = parent.STANDING
	
	#locked into run attack, supply movement direction
	if (parent.current_state == parent.RUN_ATTACKING):
		parent.move_vector = Vector2(parent.facing_direction, 0)
		
	if (parent.move_vector.length_squared() != 0):
		# resolve movement speed based on character state
		if (parent.current_state in parent.JUMPING_STATES):
			parent.move_vector.x *= (MOVESPEED_X_JUMP * parent.current_state_ctx.move_factor)
		elif (parent.current_state == parent.RUNNING 
		|| parent.current_state == parent.RUN_ATTACKING):
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
			parent.facing_direction = parent.DIR_LEFT
			if (parent.catch_point.get_pos().x > 0):
				UTILS.mirror_pos(parent.catch_point, "x")
		elif (parent.move_vector.x > 0 and frame_action == CONST.INPUT_ACTION_MOVE_RIGHT):
			parent.facing_direction = parent.DIR_RIGHT
			if (parent.catch_point.get_pos().x < 0):
				UTILS.mirror_pos(parent.catch_point, "x")
	else:
		#only apply idle animation if no other
		#animation was chosen as part of the logic
		if (not parent.current_state in NON_RESET_STATES):
			parent.current_state = parent.STANDING
			parent.next_anim = CONST.PLAYER_ANIM_IDLE
	
	#clear animation state if attacking
	if (parent.current_state in attacks.ATTACK_STATES):
		parent.next_anim = null
	
	
	#if there was move input in last frame, lets record action release
	if (!last_frame_action.empty() and frame_action.empty()):
		last_action_up = {
			"time": parent.timer,
			"action": last_frame_action
		}
	last_frame_action = frame_action