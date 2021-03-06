#global state constants
#add var with line 
#  
#  onready var CONST = get_node("/root/const")
#
#to use
extends Node

const VECTOR2_ZERO = Vector2(0, 0)
const FILE_PATH_NAMES_DB = "res://autoload/names-randomized.db"

const PLAYER_ATTACKS_CONFIG_FILE_PATH = "res://characters/player/attacks/attacks.ini"
const THUG_ATTACKS_CONFIG_FILE_PATH = "res://characters/enemies/thug/attacks.ini"
const HIT_EFFECTS_FOLDER_PATH = "res://characters/hit_effects/"
const ENEMIES_POOL_CLASS = "res://stages/enemies_pool.gd"
#player animations names
const PLAYER_ANIM_IDLE = "player_idle"
const PLAYER_ANIM_WALK = "player_walk"
const PLAYER_ANIM_RUN = "player_run"
const PLAYER_ANIM_JUMP_START = "player_jump_start"
const PLAYER_ANIM_JUMP_AIR = "player_jump_air"
const PLAYER_ANIM_CATCHING = "player_catching"
#attack animations
const PLAYER_ANIM_ATTACK_1 = "player_attack_1"
const PLAYER_ANIM_ATTACK_2 = "player_attack_2"
const PLAYER_ANIM_ATTACK_3 = "player_attack_3"
const PLAYER_ANIM_ATTACK_4 = "player_attack_4"
const PLAYER_ANIM_ATTACK_JUMP_SLOW = "player_attack_jump_slow"
const PLAYER_ANIM_ATTACK_JUMP_RUN = "player_attack_jump_run"
const PLAYER_ANIM_CATTACK_1 = "player_catch_attack_1"
const PLAYER_ANIM_CATTACK_2 = "player_catch_attack_2"
const PLAYER_ANIM_CATTACK_3 = "player_catch_attack_3"
const PLAYER_ANIM_CATCH_THROW = "player_catch_throw"
const PLAYER_ANIM_RUN_ATTACK = "player_run_attack"
#hurt animations
const PLAYER_ANIM_HURTING = "player_hurting"
const PLAYER_ANIM_FALLING_FWD = "player_falling_forward"
const PLAYER_ANIM_FALLING_BCK = "player_falling_backward"
const PLAYER_ANIM_ON_BACK = "player_fall_on_back"
const PLAYER_ANIM_ON_BELLY = "player_fall_on_belly"
const PLAYER_ANIM_DEATH_ON_BACK = "player_death_on_back"
const PLAYER_ANIM_DEATH_ON_BELLY = "player_death_on_belly"


#common animation to receive hit
const ANIM_HIT= "hit_spark"


#SIGNALS
const SIG_ENEMY_DEATH = "enemy_death"
const SIG_ENEMY_POOL_FINISHED = "enemy_pool_finished"
const SIG_ENEMY_POOL_ADD_NEW = "enemy_pool_add_new"
const SIG_PLAYER_MAX_HP = "set_max_hp"
const SIG_PLAYER_SET_HP = "set_health"

#player input actions, defined in project settings
const INPUT_ACTION_MOVE_LEFT = "move_left"
const INPUT_ACTION_MOVE_RIGHT = "move_right"
const INPUT_ACTION_MOVE_UP = "move_up"
const INPUT_ACTION_MOVE_DOWN = "move_down"
const INPUT_ACTION_JUMP = "jump"
const INPUT_ACTION_ATTACK = "attack"

#how many milliseconds of input pause are allowed
#to be considered a double-tap
const DOUBLE_TAP_INTERVAL_SEC = 0.15

#group of objects that are level characters like player or enemies
#useful to know who gets a dropshadow
const GROUP_CHARS = "characters"
const GROUP_ENEMIES = "enemies"
const GROUP_PLAYER = "player"


#enemy animation names
const THUG_ANIM_IDLE = "thug_idle"
const THUG_ANIM_MOVE = "thug_walk"
const THUG_ANIM_ATTACK_1 = "thug_attack_1"
const THUG_ANIM_ATTACK_2 = "thug_attack_2"
const THUG_ANIM_HURTING = "thug_hurting"
const THUG_ANIM_FALLING_FWD = "thug_falling_forward"
const THUG_ANIM_FALLING_BCK = "thug_falling_backward"
const THUG_ANIM_ON_BACK = "thug_fall_on_back"
const THUG_ANIM_ON_BELLY = "thug_fall_on_belly"
const THUG_ANIM_DEATH_ON_BACK = "thug_death_on_back"
const THUG_ANIM_DEATH_ON_BELLY = "thug_death_on_belly"
const THUG_ANIM_CAUGHT = "thug_caught"
const THUG_ANIM_CAUGHT_HURT = "thug_caught_hurt"


#Level constants
const LEVEL_1_ENEMY_PLACEMENT = "res://stages/level_1/enemies.json"
const LEVEL_X_START_SIGNAL = "reached_level_start_x"
const LEVEL_X_END_SIGNAL = "reached_level_end_x"
const CHARACTER_LEVEL_BOUNDS_X_METHOD = "reached_bound_x"