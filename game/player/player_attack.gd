extends Node2D
#quick access to constnats
onready var CONST = get_node("/root/const")

enum ATTACK_STATES {ATTACK1 = 0, ATTACK2 = 1, ATTACK3 = 2, ATTACK4 = 3}
onready var ATTACK_ANIMATIONS = [
	CONST.PLAYER_ANIM_ATTACK_1,
	CONST.PLAYER_ANIM_ATTACK_2
]
#howe much time at end of attack animation next input is awaited
const ANIMATION_INPUT_TAIL = 0.2

#access to main character node
onready var parent = get_node("../")
#access to movement, to know what attack to switch to
onready var movement = get_node("../player_move")
onready var sprite = get_node("sprites")
onready var anim = get_node("anim")

#is the character locked into an attack and cant move right now
var locked = false
#are the attacks connecting to something? 
#combo cant be continued if they dont
var hitting = false
var attacking
var curr_anim = ""
var attack_state
var input_waits = {}
var input_wait = 0.0
var next_anim 

func _ready():
	attacking = false
	attack_state = null
	for animation in ATTACK_ANIMATIONS:
		input_waits[animation] = anim.get_animation(animation).get_length() - ANIMATION_INPUT_TAIL
		
	anim.play(CONST.PLAYER_ANIM_ATTACK_IDLE)
	set_process(true)
	
func _process(delta):
	#start attack
	next_anim = null
	if (!attacking and Input.is_action_pressed(CONST.INPUT_ACTION_ATTACK)):
		attacking = true
		#cant move at start of attack
		locked = true
		attack_state = ATTACK1
		next_anim = CONST.PLAYER_ANIM_ATTACK_1
		input_wait = input_waits[next_anim]
	elif (attacking):
		input_wait -= delta
		if (input_wait < 0.0):
			locked = false
			if (Input.is_action_pressed(CONST.INPUT_ACTION_ATTACK)):
				if (attack_state < ATTACK2 
					or (hitting and attack_state < ATTACK4)):
					locked = true
					attack_state += 1
					next_anim = "attack_" + str(attack_state + 1)
					input_wait = input_waits[next_anim]
					#also add to input the current animation length
					input_wait += (anim.get_current_animation_length() - anim.get_current_animation_pos())
				else:
					reset_attack_state()
			#combo finished
			else:
				#finish current attack naimation first
				if (anim.is_playing()):
					input_wait = anim.get_current_animation_length() - anim.get_current_animation_pos()
				else: 	
					reset_attack_state()
				
	if (next_anim == null and !attacking):
		next_anim = CONST.PLAYER_ANIM_ATTACK_IDLE
		anim.play(next_anim)
		parent.switch_mode(false)
	
	if (next_anim != null and next_anim != curr_anim):
		#if this is a legitimate attack sequence, we wait for previous 
		#animation to stop playing first
		if (curr_anim.substr(0, 6) == "attack"):
			anim.queue(next_anim)
		else:
			anim.play(next_anim)
		curr_anim = next_anim


func reset_attack_state():
	locked = false
	attacking = false
	attack_state = null
	next_anim = null
	input_wait = 0.0
