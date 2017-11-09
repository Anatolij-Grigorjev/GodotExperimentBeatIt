extends Node2D
#quick access to constnats
onready var CONST = get_node("/root/const")

enum COMBO_ATTACKS {
ATTACK1 = 0, 
ATTACK2 = 1, 
ATTACK3 = 2, 
ATTACK4 = 3
}
#last allowed combo attack without hitting
const LAST_NON_COMBO = ATTACK4
#last attack in complete combo
const LAST_COMBO = ATTACK4

onready var ATTACK_ANIMATIONS = [
	CONST.PLAYER_ANIM_ATTACK_1,
	CONST.PLAYER_ANIM_ATTACK_2,
	CONST.PLAYER_ANIM_ATTACK_3,
	CONST.PLAYER_ANIM_ATTACK_4,
	CONST.PLAYER_ANIM_ATTACK_JUMP_ASCEND,
	CONST.PLAYER_ANIM_ATTACK_JUMP_DESCEND
]

const INPUT_Q_SIZE = 15
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
var combo_attack_state
#array of attack inputs, gathered as the player 
#keeps releasing things from the ACTIONS array, 
#others are ignored
var inputs = []
#array of hit states of combo attacks. 
#if a combo didnt connect at some attack index, 
#then it should stop happening
var attack_hits = []
var inputs_idx
var inputs_insert_idx

func _ready():
	combo_attack_state = null
	pressing = {}
	for action in ACTIONS:
		pressing[action] = false
	for attack in COMBO_ATTACKS:
		attack_hits.append(false)
	inputs_idx = 0
	inputs_insert_idx = 0
	set_process(true)
	
func _process(delta):
	
	var next_action = inputs[inputs_idx] if inputs_idx < inputs.size() else null
	#movement inputs for attack are ignored (for now)
	if (next_action != null and !next_action.begins_with("move")):
		print("next action: " + next_action)
		inputs_idx = (inputs_idx + 1) % INPUT_Q_SIZE
		if (movement.jump_state == null):
			ground_attack()
		#mid-jump-attacks, one per jump
		else:
			jump_attack()
	elif(parent.current_state == parent.ATTACKING):
		#movement inputs are locked as long as the attack is happening
		locked = parent.anim.is_playing() and (parent.curr_anim in ATTACK_ANIMATIONS)
		if (!locked):
			reset_combo_attack_state()
	
	
	#gather inputs for next frame
	for action in ACTIONS:
		if (Input.is_action_pressed(action)):
			if (!pressing[action]):
				pressing[action] = true
		elif (pressing[action]):
			#let go of action on previous frame, log the command
			inputs.insert(inputs_insert_idx, action)
			inputs_insert_idx = (inputs_insert_idx + 1) % INPUT_Q_SIZE
			pressing[action] = false
			print(inputs)

func clear_inputs():
	print("clearing inputs")
	inputs.clear()
	for idx in range(attack_hits.size()):
		attack_hits[idx] = false
	inputs_idx = 0
	inputs_insert_idx = 0
	
func reset_combo_attack_state():
	locked = false
	parent.current_state = parent.STANDING if movement.jump_state == null else parent.JUMPING
	combo_attack_state = null
	clear_inputs()
	
func ground_attack():
	if (combo_attack_state == null):
		#not attacking yet, so first combo hit
		parent.current_state = parent.ATTACKING
		#cant move at start of attack
		start_combo()
	else:
		#already attacking, extend combo due to action
		if (combo_attack_state < LAST_NON_COMBO):
			continue_combo()
		#landed hits later in combo, extend it further
		elif (combo_attack_state < LAST_COMBO 
		and attack_hits[combo_attack_state]):
			continue_combo()
		else:
			if (!parent.anim.is_playing() and parent.curr_anim in ATTACK_ANIMATIONS):
				print("reset when animation not playing")
				reset_combo_attack_state()
				
func start_combo():
	queue_combo_move(ATTACK1, CONST.PLAYER_ANIM_ATTACK_1)
				
func continue_combo():
	queue_combo_move(
	combo_attack_state + 1,
	"player_attack_" + str(combo_attack_state + 1)
	)

func queue_combo_move(new_attack_state, new_anim):
	locked = true
	combo_attack_state = new_attack_state
	parent.next_anim = new_anim
				
func jump_attack():
	#attack depends on the jump state
	for jump_state in JUMP_STATE_TO_ATTACK:
		if (movement.jump_state == jump_state):
			#start jump ascend attack
			if (parent.current_state != parent.ATTACKING):
				parent.current_state = parent.ATTACKING
				locked = true
				parent.next_anim = (JUMP_STATE_TO_ATTACK[jump_state])
			#attack already ahppening, ignore input and wait
			else:
				if (!parent.anim.is_playing()):
					clear_inputs()
