extends Node2D
#quick access to constnats
onready var CONST = get_node("/root/const")

enum COMBO_ATTACKS {
	ATTACK1 = 0, 
	ATTACK2 = 1, 
	ATTACK3 = 2, 
	ATTACK4 = 3,
	CATCH_ATTACK_1 = 4,
	CATCH_ATTACK_2 = 5,
	CATCH_ATTACK_3 = 6
}
onready var hitboxes = get_node("../sprites/attack_hitboxes")
onready var catch_point = get_node("../sprites/catch_collider")
#last allowed combo attack without hitting anything
const LAST_NON_COMBO = ATTACK2
#last attack in complete combo
const LAST_COMBO = ATTACK4
#last attack in catch combo
const LAST_CATCH_COMBO = CATCH_ATTACK_3
#time in seconds after hit finishes that 
#the character remains in an ATTACKING state and ready to combo
const MAX_COMBO_COUNTDOWN = 0.2

onready var ATTACK_ANIMATIONS = [
	CONST.PLAYER_ANIM_ATTACK_1,
	CONST.PLAYER_ANIM_ATTACK_2,
	CONST.PLAYER_ANIM_ATTACK_3,
	CONST.PLAYER_ANIM_ATTACK_4,
	CONST.PLAYER_ANIM_ATTACK_JUMP_ASCEND,
	CONST.PLAYER_ANIM_ATTACK_JUMP_DESCEND,
	CONST.PLAYER_ANIM_CATTACK_1,
	CONST.PLAYER_ANIM_CATTACK_2,
	CONST.PLAYER_ANIM_CATTACK_3,
	CONST.PLAYER_ANIM_RUN_ATTACK,
]

#access to main character node
onready var parent = get_node("../")
#access to movement, to know what attack to switch to
onready var movement = get_node("../player_move")

onready var ATTACK_STATES = [
	parent.ATTACKING,
	parent.CATCH_ATTACKING,
	parent.RUN_ATTACKING,
]
onready var CATCHING_STATES = [
	parent.CATCHING,
	parent.CATCH_ATTACKING,
]

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
#should the update loop finish attack
# sequence regardless of input
var finish_attack = false
#attack inputs collected for next frame
var pressing = {}
#latest performed attack within combo time limit
var last_combo_attack
#current countdown of combo sequence 
var current_combo_countdown
#injected when player hitboxes are done being set up
var end_catch_disloge = Vector2()

func _ready():
	last_combo_attack = null
	current_combo_countdown = 0
	pressing = {}
	for action in ACTIONS:
		pressing[action] = false

	set_process(true)
	#set disloge for end of catch combo
	
func _process(delta):
		
	#gather inputs for frame
	for action in ACTIONS:
		pressing[action] = Input.is_action_pressed(action)

	#if we are attacking, 
	#lets ignore input while the animation plays out
	if (parent.current_state in ATTACK_STATES):
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
	if (pressing[CONST.INPUT_ACTION_ATTACK] || finish_attack):
		#regular cathc attack
		if (parent.current_state in CATCHING_STATES):
			catch_attack()
		#regular ground combo
		elif (movement.jump_state != null):
			#mid-jump-attacks
			jump_attack()
		else:
			if (parent.current_state == parent.RUNNING): 
				run_attack()
			else:
				ground_attack()
		return
	
	
	
func reset_attack_state():
	locked = false
	finish_attack = false
	if (parent.caught_enemy != null):
		parent.current_state = parent.CATCHING
	elif (movement.jump_state != null):
		parent.current_state = parent.JUMPING
	else:
		parent.current_state = parent.STANDING
	last_combo_attack = null
	current_combo_countdown = 0
	hitting = false
	hitboxes.reset_attacks()

func catch_attack():
	#add to catch point longevity when in this method
	#since any hit adds to it and if its the last one, 
	#enemy is let go anyway
	catch_point.catch_hold_duration = clamp(
		catch_point.catch_hold_duration + MAX_COMBO_COUNTDOWN, 
		0.0, 
		catch_point.MAX_CATCH_HOLD_DURATION
	)
	if (last_combo_attack == null):
		#not catch attacking yet
		parent.current_state = parent.CATCH_ATTACKING
		
		start_catch_attack()
	else:
		#extend catch attack if not at limit
		if (last_combo_attack <= LAST_CATCH_COMBO and hitting):
			continue_catch_attack()
			if (last_combo_attack > LAST_CATCH_COMBO):
				finish_attack = true
		else:
			if (!parent.anim.is_playing() and parent.curr_anim in ATTACK_ANIMATIONS):
				#release person in attack, catch combo over
				if (last_combo_attack >= LAST_CATCH_COMBO):
					parent.release_enemy(end_catch_disloge)
				else:
					parent.release_enemy() 
				#also stop animation when its over
				reset_attack_state()

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
			if (last_combo_attack > LAST_COMBO):
				finish_attack = true
		else:
			if (!parent.anim.is_playing() and parent.curr_anim in ATTACK_ANIMATIONS):
				reset_attack_state()
				
func start_combo():
	queue_combo_move(ATTACK1, CONST.PLAYER_ANIM_ATTACK_1)

func start_catch_attack():
	queue_combo_move(CATCH_ATTACK_1, CONST.PLAYER_ANIM_CATTACK_1)
				
func continue_combo():
	queue_combo_move(
	last_combo_attack + 1,
	"player_attack_" + str(last_combo_attack + 1)
	)

#catch attack animations are offset by length of CATCH_ATTACK	
func continue_catch_attack():
	queue_combo_move(
	last_combo_attack + 1,
	"player_catch_attack_" + str(last_combo_attack - CATCH_ATTACK_1 + 1)
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
					
func run_attack():
	#start run attack
	if (parent.current_state != parent.RUN_ATTACKING):
		parent.current_state = parent.RUN_ATTACKING
		locked = true
		parent.next_anim = CONST.PLAYER_ANIM_RUN_ATTACK
	else:
		if (!parent.anim.is_playing() and parent.curr_anim in ATTACK_ANIMATIONS):
			reset_attack_state()
