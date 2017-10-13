extends Node2D
#quick access to constnats
onready var CONST = get_node("/root/const")

enum ATTACK_STATES {ATTACK1 = 0, ATTACK2 = 1, ATTACK3 = 2, ATTACK4 = 3}
onready var ATTACK_ANIMATIONS = [
	CONST.PLAYER_ANIM_ATTACK_1,
	CONST.PLAYER_ANIM_ATTACK_2
]
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

#is the character locked into an attack and cant move right now
var locked = false
#are the attacks connecting to something? 
#combo cant be continued if they dont
var hitting = false
var pressing
var attacking
var curr_anim = ""
var attack_state
var inputs = []
var inputs_idx
var inputs_insert_idx

func _ready():
	attacking = false
	attack_state = null
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
		inputs_idx = (inputs_idx + 1) % INPUT_Q_SIZE
		#start of attack
		if (!attacking):
			attacking = true
			#cant move at start of attack
			locked = true
			attack_state = ATTACK1
			anim.play(CONST.PLAYER_ANIM_ATTACK_1)
		else:
			#already attacking, extend combo due to action
			if (attack_state < ATTACK2):
				locked = true
				attack_state += 1
				anim.queue("attack_" + str(attack_state + 1))
			else:
				if (!anim.is_playing()):
					reset_attack_state()
	elif(attacking):
		attacking = anim.is_playing()
		locked = attacking
	elif (!attacking):
		reset_attack_state()
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


func reset_attack_state():
	locked = false
	attacking = false
	attack_state = null
	inputs.clear()
	inputs_idx = 0
	inputs_insert_idx = 0
