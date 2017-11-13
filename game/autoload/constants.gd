#global state constants
#add var with line 
#  
#  onready var CONST = get_node("/root/const")
#
#to use
extends Node

const VECTOR2_ZERO = Vector2(0, 0)

const PLAYER_ATTACKS_CONFIG_FILE_PATH = "res://characters/player/attacks/attacks.ini"
const HIT_EFFECTS_FOLDER_PATH = "res://characters/hit_effects/"
const ENEMIES_POOL_CLASS = "res://stages/enemies_pool.gd"
#player animations names
const PLAYER_ANIM_IDLE = "player_idle"
const PLAYER_ANIM_WALK = "player_walk"
const PLAYER_ANIM_RUN = "player_run"
const PLAYER_ANIM_JUMP_START = "player_jump_start"
const PLAYER_ANIM_JUMP_AIR = "player_jump_air"
#attack animations
const PLAYER_ANIM_ATTACK_1 = "player_attack_1"
const PLAYER_ANIM_ATTACK_2 = "player_attack_2"
const PLAYER_ANIM_ATTACK_3 = "player_attack_3"
const PLAYER_ANIM_ATTACK_4 = "player_attack_4"
const PLAYER_ANIM_ATTACK_JUMP_ASCEND = "player_attack_jump_ascend"
const PLAYER_ANIM_ATTACK_JUMP_DESCEND = "player_attack_jump_descend"


#common animation to receive hit
const ANIM_HIT= "hit_spark"

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
const GROUP_PLAYER_SWORD = "player_sword"


#enemy animation names
const THUG_ANIM_IDLE = "thug_idle"
const THUG_ANIM_MOVE = "thug_walk"
const THUG_ANIM_ATTACK_1 = "thug_attack_1"
const THUG_ANIM_HURTING = "thug_hurting"
const THUG_ANIM_FALLING_FWD = "thug_falling_forward"
const THUNG_ANIM_FALLING_BCK = "thug_falling_backward"
const THUG_ANIM_CAUGHT = "thug_caught"
const THUG_ANIM_CAUGHT_HURT = "thug_caught_hurt"



#Level constants
#JSON value for when enemy appearing behind player
const STOP_AREA_ENEMY_MIN = "left"
#JSON value for when enemy appearing in front of player
const STOP_AREA_ENEMY_MAX = "right"

const LEVEL_1_ENEMY_PLACEMENT = "res://stages/level_1/enemies.json"