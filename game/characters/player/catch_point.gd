extends Area2D

#quick access to constnats
onready var CONST = get_node("/root/const")
onready var parent = get_node("../")

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
	#set the porper states
	body.current_state = parent.CAUGHT
	parent.current_state = parent.CATCHING
	parent.caught_enemy = body
	body.set_global_pos(parent.catch_point.get_global_pos())