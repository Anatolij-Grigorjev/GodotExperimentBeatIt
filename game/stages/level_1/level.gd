extends Node

onready var CONST = get_node("/root/const")

onready var player = get_node("player")
onready var ground = get_node("ground")
onready var stop_1 = get_node("stop_1")

var player_current_bounds_x = null

func _ready():
	var tex_extents = ground.texture_extents
	player.get_node("camera").set_limit(MARGIN_BOTTOM, tex_extents.y * 2)
	set_process(true)
	
func _process(delta):
	for character in get_tree().get_nodes_in_group(CONST.GROUP_CHARS):
		if (!character.movement.jumping):
			var feet_pos = character.feet_pos
			var good_feet_pos = ground.nearest_in_bounds(feet_pos)
			if (feet_pos != good_feet_pos):
				character.set_pos_by_feet(good_feet_pos)
		var good_min = ground.nearest_in_general_bounds(character.min_pos)
		if (good_min.x > character.min_pos.x):
			character.set_pos_by_min(good_min)
		var good_max = ground.nearest_in_general_bounds(character.max_pos)
		if (good_max.x < character.max_pos.x):
			character.set_pos_by_max(good_max)
		#use plaeyr camera bounds to limit enemy movements as well
		#but enemies can at most position themselves out of view
		if (character != player and player_current_bounds_x != null):
			if (character.max_pos.x < player_current_bounds_x.x):
				character.set_pos_by_max(Vector2(player_current_bounds_x.x + 1, character.max_pos.y))
			if (character.min_pos.x > player_current_bounds_x.y):
				character.set_pos_by_min(Vector2(player_current_bounds_x.y - 1, character.min_pos.y))
		
	if (player_current_bounds_x != null):
		if (player.min_pos.x < player_current_bounds_x.x):
			player.set_pos_by_min(Vector2(player_current_bounds_x.x + 1, player.min_pos.y))
		if (player.max_pos.x > player_current_bounds_x.y):
			player.set_pos_by_max(Vector2(player_current_bounds_x.y - 1, player.max_pos.y))

func _on_stop_1_area_enter( area ):
	if (area.get_name() == "player"):
		#time to stop player camera and do overhead one
		area.get_node("camera").clear_current()
		set_area_activeness(stop_1, true)
		pass # replace with function body


func _on_stop_1_area_exit( area ):
	if (area.get_name() == "player"):
		#time to stop overhead camera and do player one
		set_area_activeness(stop_1, false)
		area.get_node("camera").make_current()
		#remove this stop later since its been dealt with
		stop_1.queue_free()


func set_area_activeness(area, active = true):
	if (active):
		area.get_node("camera").make_current()
		var collider = area.get_node("collider")
		var area_extents = collider.get_shape().get_extents() * area.get_scale()
		var scaled_pos_x = collider.get_pos().x * area.get_scale().x
		#set x bounds using collide extents and position
		player_current_bounds_x = Vector2(
		area.get_pos().x + scaled_pos_x - area_extents.x, 
		area.get_pos().x + scaled_pos_x + area_extents.x)
	else:
		area.get_node("camera").clear_current()
		player_current_bounds_x = null