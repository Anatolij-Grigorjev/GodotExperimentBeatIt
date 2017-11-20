extends Node2D
#quick access to constnats
onready var CONST = get_node("/root/const")

enum COMBO_ATTACKS {
	ATTACK1 = 0, 
	ATTACK2 = 1, 
	ATTACK3 = 2, 
	ATTACK4 = 3
}
onready var hitboxes = get_node("../sprites/attack_hitboxes")
#last allowed combo attack without hitting anything
const LAST_NON_COMBO = ATTACK4
#last attack in complete combo
const LAST_COMBO = ATTACK4
#time in seconds after hit finishes that 
#the character remains in an ATTACKING state and ready to combo
const MAX_COMBO_COUNTDOWN = 0.25

onready var ATTACK_ANIMATIONS = [
	CONST.PLAYER_ANIM_ATTACK_1,
	CONST.PLAYER_ANIM_ATTACK_2,
	CONST.PLAYER_ANIM_ATTACK_3,
	CONST.PLAYER_ANIM_ATTACK_4,
	CONST.PLAYER_ANIM_ATTACK_JUMP_ASCEND,
	CONST.PLAYER_ANIM_ATTACK_JUMP_DESCEND
]

#access to main character node
onready var parent = get_node("../")
#access to movement, to know what attack to switch to
onready var movement = get_node("../player_move")

onready var ACTIONS = [
	CONST.INPUT_ACTION_ATTACK,
	CONST.INPUT_ACTION_MOVE_LEFT,
	CONST.INPUT_ACTION_MOVE_RIGHT,
	CONST.INPUT_ACTION_MOVE_UP,
	CONST.INPUT_ACTION_MOVE_DOWN
]
onready var JUMP_STATE_TO_ATTACK = {
	movement.JUMP_STATES.ASCEND: CONST.PLAYER_ANIM_ATTACK_JUMP_ASCEND,
	movement.JUMP_STATES.DESCEND: CONST.PLAYER_ANIM_ATTACK_JUMP_DESCEND
}

#is the character locked into an attack and cant move right now
var locked = false
#are the attacks connecting to something? 
#combo cant be continued if they dont
var hitting = false
#attack inputs collected for next frame
var pressing = {}
#latest performed attack within combo time limit
var last_combo_attack
#current countdown of combo sequence 
var current_combo_countdown

func _ready():
	last_combo_attack = null
	current_combo_countdown = 0
	pressing = {}
	for action in ACTIONS:
		pressing[action] = false

	set_process(true)
	
func _process(delta):
		
	#gather inputs for frame
	for action in ACTIONS:
		pressing[action] = Input.is_action_pressed(action)

	#if we are attacking, 
	#lets ignore input while the animation plays out
	if (parent.current_state == parent.ATTACKING):
		#parent still playing some attack animation, no updates needed
		if (parent.anim.is_playing() and parent.curr_anim in ATTACK_ANIMATIONS):
			return
		#parent not playing attack, lets work with the combo cooldown
		if (current_combo_countdown > 0):
			current_combo_countdown -= delta
		else:
			#marks end of a combo sequence, go to different states immediately
			reset_attack_state()
			return
	#if attack was pressed
	if (pressing[CONST.INPUT_ACTION_ATTACK]):
		#regular ground combo
		if (movement.jump_state == null):
			ground_attack()
		#mid-jump-attacks
		else:
			jump_attack()
	
	
	
func reset_attack_state():
	locked = false
	parent.current_state = parent.STANDING if movement.jump_state == null else parent.JUMPING
	last_combo_attack = null
	current_combo_countdown = 0
	hitting = false
	hitboxes.reset_attacks()
	
func ground_attack():
	if (last_combo_attack == null):
		#not attacking yet, so first combo hit
		parent.current_state = parent.ATTACKING

		start_combo()
	else:
		#already attacking, extend combo due to action
		if (last_combo_attack <= LAST_NON_COMBO):
			continue_combo()
		#landed hits later in combo, extend it further
		elif (last_combo_attack <= LAST_COMBO and hitting):
			continue_combo()
		else:
			if (!parent.anim.is_playing() and parent.curr_anim in ATTACK_ANIMATIONS):
				reset_attack_state()
				
func start_combo():
	queue_combo_move(ATTACK1, CONST.PLAYER_ANIM_ATTACK_1)
				
func continue_combo():
	queue_combo_move(
	last_combo_attack + 1,
	"player_attack_" + str(last_combo_attack + 1)
	)

func queue_combo_move(new_attack_state, new_anim):
	locked = true
	last_combo_attack = new_attack_state
	current_combo_countdown = MAX_COMBO_COUNTDOWN
	parent.next_anim = new_anim
				
func jump_attack():
	#attack depends on the jump state
	for jump_state in JUMP_STATE_TO_ATTACK:
		if (movement.jump_state == jump_state):
			#start jump ascend attack
			if (parent.current_state != parent.ATTACKING):
				parent.current_state = parent.ATTACKING
				current_combo_countdown = MAX_COMBO_COUNTDOWN
				locked = true
				parent.next_anim = (JUMP_STATE_TO_ATTACK[jump_state])
			#attack already ahppening, ignore input and wait
			else:
				if (!parent.anim.is_playing() and parent.curr_anim in ATTACK_ANIMATIONS):
					reset_attack_state()
