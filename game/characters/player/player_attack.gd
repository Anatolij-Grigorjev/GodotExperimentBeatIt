extends Node2D
#quick access to constnats
onready var CONST = get_node("/root/const")

enum combo_attack_stateS {ATTACK1 = 0, ATTACK2 = 1, ATTACK3 = 2, ATTACK4 = 3}
onready var ATTACK_ANIMATIONS = [
	CONST.PLAYER_ANIM_ATTACK_1,
	CONST.PLAYER_ANIM_ATTACK_2
]
onready var ATTACK_EFFECT_Z = {
	CONST.PLAYER_ANIM_ATTACK_1: 10,
	CONST.PLAYER_ANIM_ATTACK_2: 7
}
const INPUT_Q_SIZE = 15
#access to main character node
onready var parent = get_node("../")
#access to movement, to know what attack to switch to
onready var movement = get_node("../player_move")
onready var sprite = get_node("sprites")
onready var anim = get_node("anim")

onready var ACTIONS = [
	CONST.INPUT_ACTION_ATTACK
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
var pressing
var attacking
var curr_anim = ""
var combo_attack_state
var inputs = []
var inputs_idx
var inputs_insert_idx

func _ready():
	attacking = false
	combo_attack_state = null
	pressing = {
		CONST.INPUT_ACTION_ATTACK: false
	}
	anim.play(CONST.PLAYER_ANIM_ATTACK_IDLE)
	inputs = []
	inputs_idx = 0
	inputs_insert_idx = 0
	set_process(true)
	
func _process(delta):
	
	var next_action = inputs[inputs_idx] if inputs_idx < inputs.size() else null
	if (next_action != null):
		print("next action: " + next_action)
		inputs_idx = (inputs_idx + 1) % INPUT_Q_SIZE
		if (!movement.jumping):
			ground_attack()
		#mid-jump-attacks, one per jump
		else:
			jump_attack()
	elif(attacking):
		attacking = anim.is_playing()
		locked = attacking
	elif (!attacking && parent.attacking):
		print("reset when not attacking anymore")
		reset_combo_attack_state()
		anim.play(CONST.PLAYER_ANIM_ATTACK_IDLE)
		parent.switch_mode(false)
	
	
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
			print(inputs.size())

func clear_inputs():
	print("clearing inputs")
	inputs.clear()
	inputs_idx = 0
	inputs_insert_idx = 0
	
func reset_combo_attack_state():
	locked = false
	attacking = false
	combo_attack_state = null
	clear_inputs()
	
func ground_attack():
	#start of attack
	
	if (!attacking):
		parent.switch_mode(true)
		attacking = true
		#cant move at start of attack
		locked = true
		combo_attack_state = ATTACK1
		anim.play(CONST.PLAYER_ANIM_ATTACK_1)
	else:
		#already attacking, extend combo due to action
		if (combo_attack_state < ATTACK2):
			locked = true
			combo_attack_state += 1
			anim.queue("player_attack_" + str(combo_attack_state + 1))
		else:
			if (!anim.is_playing()):
				print("reset when animation not playing")
				reset_combo_attack_state()
				
func jump_attack():
	#attack depends on the jump state
	for jump_state in JUMP_STATE_TO_ATTACK:
		if (movement.jump_state == jump_state):
			#start jump ascend attack
			if (!attacking):
				parent.switch_mode(true)
				attacking = true
				locked = true
				anim.play(JUMP_STATE_TO_ATTACK[jump_state])
			#attack already ahppening, ignore input and wait
			else:
				attacking = anim.is_playing()
				if (!attacking):
					clear_inputs()
					parent.switch_mode(false)
