extends "../basic_movement.gd"

onready var movement = get_node("player_move")
onready var attacks = get_node("player_attack")
var move_extents = Vector2()
var attack_extents = Vector2()

var moving = true
var attacking = false

onready var MOVEMENT_COMMANDS = [ 
	CONST.INPUT_ACTION_MOVE_LEFT, 
	CONST.INPUT_ACTION_MOVE_RIGHT, 
	CONST.INPUT_ACTION_MOVE_UP, 
	CONST.INPUT_ACTION_MOVE_DOWN, 
	CONST.INPUT_ACTION_JUMP
]
onready var ATTACK_COMMANDS = [
	CONST.INPUT_ACTION_ATTACK
]

func _ready():
	move_extents = UTILS.get_sprite_extents(movement.sprite)
	attack_extents = UTILS.get_sprite_extents(attacks.sprite)
	current_extents = move_extents
	switch_mode(attacking)
	._ready()

func _process(delta):
	
	#switch character mode based on input
	if (moving and !movement.locked):
		for action in ATTACK_COMMANDS:
			if (Input.is_action_pressed(action)):
				switch_mode(true)
	elif (attacking and !attacks.locked):
		for action in MOVEMENT_COMMANDS:
			if (Input.is_action_pressed(action)):
				print("movement action: " + action)
				switch_mode(false)
	
	._process(delta)

	
func switch_mode(to_attacking):
	print("switch mode to attack: " + str(to_attacking))
	if (to_attacking):
		current_extents = attack_extents
		attacks.show()
		movement.hide()
	else: 
		current_extents = move_extents
		attacks.hide()
		movement.show()
	attacking = to_attacking
	moving = !to_attacking