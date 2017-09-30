#global state constants, need to be avilable everywhere
#add var with line 
#  
#  onready var CONST = get_node("/root/const")
#
#to use
extends Node

#player animations names
const PLAYER_ANIM_IDLE = "idle"
const PLAYER_ANIM_WALK = "walk"
const PLAYER_ANIM_RUN_START = "run_start"
const PLAYER_ANIM_JUMP_START = "jump_start"

#player input actions, defined in project settings
const INPUT_ACTION_MOVE_LEFT = "move_left"
const INPUT_ACTION_MOVE_RIGHT = "move_right"
const INPUT_ACTION_MOVE_UP = "move_up"
const INPUT_ACTION_MOVE_DOWN = "move_down"
const INPUT_ACTION_JUMP = "jump"

#how many milliseconds of input pause are allowed
#to be considered a double-tap
const DOUBLE_TAP_INTERVAL_MS = 100


