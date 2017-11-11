extends Area2D

#quick access to constnats
onready var CONST = get_node("/root/const")
onready var parent = get_node("../")

onready var CATCHING_STATES = [
	parent.WALKING,
	parent.RUNNING
]

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass


func _on_catch_point_body_enter( body ):
	#collision with own body
	if ( body == parent ):
		return
	#already holding somebody, cant hold 2 guys at once
	if ( parent.caught_enemy != null ):
		return
	#only try to catch enemies
	if ( !body.is_in_group(CONST.GROUP_ENEMIES) ):
		return
	#already holding the guy
	if ( body == parent.caught_enemy ):
		return
	#can only grab currently hurting enemies
	if ( body.current_state != parent.HURTING ):
		return
	#if the player is walking towards the enemy, not standing there attacking
	if ( parent.current_state in CATCHING_STATES): 
		#set the porper states
		body.current_state = parent.CAUGHT
		parent.current_state = parent.CATCHING
		parent.caught_enemy = body
		body.set_global_pos(parent.catch_point.get_global_pos())