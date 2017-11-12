extends Node

onready var CONST = get_node("/root/const")

onready var player = get_node("player")
onready var ground = get_node("ground")
onready var stop_1 = get_node("stop_1")

var player_current_bounds_x = null

#nodes in level in the group characters. 
#this will be a list of maps where character nodes and other properties are strored
var characters_in_level = []

func _ready():
	var tex_extents = ground.texture_extents
	player.get_node("camera").set_limit(MARGIN_BOTTOM, tex_extents.y * 2)
	#populate characters info map
	for character in get_tree().get_nodes_in_group(CONST.GROUP_CHARS):
		characters_in_level.append({
			"id": character.get_name(),
			"node": character,
			"can_jump": character.has_method("jumping")
		})
	set_process(true)
	
func _process(delta):
	for character in characters_in_level:
		#check ground Z bounds when character not jumping
		if (!character.can_jump or !character.node.jumping()):
			var feet_pos = character.node.feet_pos
			var good_feet_pos = ground.nearest_in_bounds(feet_pos)
			if (feet_pos != good_feet_pos):
				character.node.set_pos_by_feet(good_feet_pos)
		var good_min = ground.nearest_in_general_bounds(character.node.min_pos)
		if (good_min.x > character.node.min_pos.x):
			character.node.set_pos_by_min(good_min)
		var good_max = ground.nearest_in_general_bounds(character.node.max_pos)
		if (good_max.x < character.node.max_pos.x):
			character.node.set_pos_by_max(good_max)
		#use plaeyr camera bounds to limit enemy movements as well
		#but enemies can at most position themselves out of view
		if (character.node != player and player_current_bounds_x != null):
			if (character.node.max_pos.x < player_current_bounds_x.x):
				character.node.set_pos_by_max(Vector2(player_current_bounds_x.x + 1, character.node.max_pos.y))
			if (character.node.min_pos.x > player_current_bounds_x.y):
				character.node.set_pos_by_min(Vector2(player_current_bounds_x.y - 1, character.node.min_pos.y))
		
	if (player_current_bounds_x != null):
		if (player.min_pos.x < player_current_bounds_x.x):
			player.set_pos_by_min(Vector2(player_current_bounds_x.x + 1, player.min_pos.y))
		if (player.max_pos.x > player_current_bounds_x.y):
			player.set_pos_by_max(Vector2(player_current_bounds_x.y - 1, player.max_pos.y))

func _on_stop_1_body_enter( body ):
	if (body.get_name() == "player"):
		#time to stop player camera and do overhead one
		body.get_node("camera").clear_current()
		set_area_activeness(stop_1, true)


func _on_stop_1_body_exit( body ):
	if (body.get_name() == "player"):
		#time to stop overhead camera and do player one
		set_area_activeness(stop_1, false)
		body.get_node("camera").make_current()
		#remove this stop later since its been dealt with
		stop_1.queue_free()


func set_area_activeness(area, active = true):
	print("seeting activeness for area " + str(area) + ": " + str(active))
	if (active):
		var camera = area.get_node("camera")
		var min_pos = area.get_node("min_stop_pos").get_global_pos()
		var max_pos = area.get_node("max_stop_pos").get_global_pos()
		setup_camera_bounds(camera, min_pos, max_pos)
		camera.make_current()
		#set x bounds for characters using prebaked positions
		player_current_bounds_x = Vector2(min_pos.x, max_pos.x)
		print("player bounds x: " + str(player_current_bounds_x))
	else:
		area.get_node("camera").clear_current()
		player_current_bounds_x = null

func setup_camera_bounds(camera, min_pos, max_pos):
	camera.set_limit(MARGIN_LEFT, min_pos.x)
	camera.set_limit(MARGIN_TOP, min_pos.y)
	camera.set_limit(MARGIN_RIGHT, max_pos.x)
	camera.set_limit(MARGIN_BOTTOM, max_pos.y)