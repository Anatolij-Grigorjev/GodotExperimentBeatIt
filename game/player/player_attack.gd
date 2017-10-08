extends Node2D
#quick access to constnats
onready var CONST = get_node("/root/const")

#access to main character node
onready var parent = get_node("../")
#access to movement, to know what attack to switch to
onready var movement = get_node("../player_move")
onready var sprite = get_node("sprites")
onready var anim = get_node("anim")

#is the character locked into an attack and cant move right now
var locked = false

func _ready():
	set_process(true)
	
func _process(delta):
	pass
