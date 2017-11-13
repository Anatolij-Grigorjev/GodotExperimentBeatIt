extends Node

onready var CONST = get_node("/root/const")
onready var UTILS = get_node("/root/utils")

onready var player = get_node("player")
onready var ground = get_node("ground")

var areas_nodes_names = [
	"stop_1"
] 
var areas_nodes = {} #node name to node mapping
var areas_info = {} #node to aux info mapping
var current_stop = null
onready var EnemiesPool = load(CONST.ENEMIES_POOL_CLASS)
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
	
	var enemies_data = UTILS.json_to_dict(CONST.LEVEL_1_ENEMY_PLACEMENT)	
	for area_name in areas_nodes_names:
		var area = get_node(area_name)
		areas_nodes[area_name] = area
		var min_pos = area.get_node("min_stop_pos").get_global_pos()
		var max_pos = area.get_node("max_stop_pos").get_global_pos()
		areas_info[area] = {
			"min_pos": min_pos,
			"max_pos": max_pos,
			"enemy_pool": EnemiesPool.new(enemies_data[area_name], #enemy data
			min_pos.x, #left X to spawn
			max_pos.x, #right X to spawn
			Vector2(min_pos.y, max_pos.y)) #Y sapwn bounds
		}
	
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
	#check player in bounds
	if (player_current_bounds_x != null):
		if (player.min_pos.x < player_current_bounds_x.x):
			player.set_pos_by_min(Vector2(player_current_bounds_x.x + 1, player.min_pos.y))
		if (player.max_pos.x > player_current_bounds_x.y):
			player.set_pos_by_max(Vector2(player_current_bounds_x.y - 1, player.max_pos.y))
	#check current stop enemies
	if (current_stop != null and player_current_bounds_x != null):
		var pool = areas_info[current_stop].enemies_pool
		if (pool.finished):
			player_current_bounds_x = null


func _on_stop_1_body_enter( body ):
	if (body.get_name() == "player"):
		#time to stop player camera and do overhead one
		body.get_node("camera").clear_current()
		set_area_activeness(areas_nodes["stop_1"], true)


func _on_stop_1_body_exit( body ):
	if (body.get_name() == "player"):
		var stop_1 = areas_nodes["stop_1"]
		#time to stop overhead camera and do player one
		set_area_activeness(stop_1, false)
		body.get_node("camera").make_current()
		#remove this stop later since its been dealt with
		areas_info[stop_1].enemy_pool.queue_free()
		areas_info.erase(stop_1)
		areas_nodes.erase("stop_1")
		stop_1.queue_free()


func set_area_activeness(area, active = true):
	print("seeting activeness for area " + str(area) + ": " + str(active))
	if (active):
		current_stop = area
		var camera = area.get_node("camera")
		var min_pos = areas_info[area].min_pos
		var max_pos = areas_info[area].max_pos
		setup_camera_bounds(camera, min_pos, max_pos)
		camera.make_current()
		#set x bounds for characters using prebaked positions
		player_current_bounds_x = Vector2(min_pos.x, max_pos.x)
		print("player bounds x: " + str(player_current_bounds_x))
	else:
		area.get_node("camera").clear_current()
		player_current_bounds_x = null
		current_stop = null

func setup_camera_bounds(camera, min_pos, max_pos):
	camera.set_limit(MARGIN_LEFT, min_pos.x)
	camera.set_limit(MARGIN_TOP, min_pos.y)
	camera.set_limit(MARGIN_RIGHT, max_pos.x)
	camera.set_limit(MARGIN_BOTTOM, max_pos.y)