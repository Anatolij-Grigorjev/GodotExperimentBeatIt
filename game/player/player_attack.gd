extends Node2D
#quick access to constnats
onready var CONST = get_node("/root/const")

enum ATTACK_STATES {ATTACK1 = 0, ATTACK2 = 1, ATTACK3 = 2, ATTACK4 = 3}
onready var ATTACK_ANIMATIONS = [
	CONST.PLAYER_ANIM_ATTACK_1,
	CONST.PLAYER_ANIM_ATTACK_2
]
#access to main character node
onready var parent = get_node("../")
#access to movement, to know what attack to switch to
onready var movement = get_node("../player_move")
onready var sprite = get_node("sprites")
onready var anim = get_node("anim")

#is the character locked into an attack and cant move right now
var locked = false
var attacking
var curr_anim = ""
var attack_state
var input_waits = {}
var input_wait = 0.0

func _ready():
	attacking = false
	attack_state = null
	for animation in ATTACK_ANIMATIONS:
		input_waits[animation] = anim.get_animation(animation).get_length() - 0.1
	set_process(true)
	
func _process(delta):
	#start attack
	var next_anim = null
	if (!attacking and Input.is_action_pressed(CONST.INPUT_ACTION_ATTACK)):
		attacking = true
		#cant move at start of attack
		locked = true
		attack_state = ATTACK1
		next_anim = CONST.PLAYER_ANIM_ATTACK_1
		input_wait = input_waits[next_anim]
	elif (attacking):
		input_wait -= delta
		if (input_wait <= 0.0):
			locked = false
			if (Input.is_action_pressed(CONST.INPUT_ACTION_ATTACK) && attack_state < ATTACK4):
				locked = true
				attack_state += 1
				next_anim = "attack_" + str(attack_state + 1)
				input_wait = input_waits[next_anim]
			#combo finished
			else:
				locked = false
				attacking = false
				attack_state = null
				next_anim = null
				input_wait = 0.0
	
	if (next_anim != null and next_anim != curr_anim):
		curr_anim = next_anim
		anim.queue(curr_anim)

