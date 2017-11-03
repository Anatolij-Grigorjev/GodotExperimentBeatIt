extends "../basic_movement.gd"

onready var movement = get_node("player_move")
onready var attacks = get_node("player_attack")

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
	._ready()

func _process(delta):
	._process(delta)

func jumping():
	return movement.jumping