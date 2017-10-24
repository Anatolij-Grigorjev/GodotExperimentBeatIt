extends "../basic_movement.gd"

onready var movement = get_node("player_move")
onready var attacks = get_node("player_attack")
var move_extents = Vector2()
var attack_extents_x = Vector2()
var attack_extents_y = Vector2()

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
	var attack_extents = UTILS.get_sprite_extents(attacks.sprite)
	attack_extents_x = Vector2(attack_extents.x, attack_extents.x)
	attack_extents_y = Vector2(
		move_extents.y, 
		attack_extents.y + (attack_extents.y - move_extents.y)
	)
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
		set_extents(attack_extents_x, attack_extents_y)
		attacks.show()
		movement.hide()
	else: 
		set_extents(move_extents)
		attacks.hide()
		movement.show()
	attacking = to_attacking
	moving = !to_attacking