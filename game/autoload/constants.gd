#global state constants
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
#attack animations
const PLAYER_ANIM_ATTACK_IDLE = "aidle"
const PLAYER_ANIM_ATTACK_1 = "attack_1"
const PLAYER_ANIM_ATTACK_2 = "attack_2"
const PLAYER_ANIM_ATTACK_JUMP_ASCEND = "attack_jump_ascend"
const PLAYER_ANIM_ATTACK_JUMP_DESCEND = "attack_jump_descend"

#actual animation state names to configure individual animations
const ANIM_NAME_JUMP_START = "jump_start"
const ANIM_NAME_JUMP_ASCEND = "jump_ascend"


#player input actions, defined in project settings
const INPUT_ACTION_MOVE_LEFT = "move_left"
const INPUT_ACTION_MOVE_RIGHT = "move_right"
const INPUT_ACTION_MOVE_UP = "move_up"
const INPUT_ACTION_MOVE_DOWN = "move_down"
const INPUT_ACTION_JUMP = "jump"
const INPUT_ACTION_ATTACK = "attack"

#how many milliseconds of input pause are allowed
#to be considered a double-tap
const DOUBLE_TAP_INTERVAL_MS = 100

#group of objects that are level characters like player or enemies
#useful to know who gets a dropshadow
const GROUP_CHARS = "characters"
const GROUP_ENEMIES = "enemies"

