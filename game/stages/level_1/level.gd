extends Node2D

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

#level signals
signal enemy_pool_finished
signal enemy_pool_add_new(enemy_node, global_feet_pos)

func _ready():
	var tex_extents = ground.texture_extents
	player.get_node("camera").set_limit(MARGIN_BOTTOM, tex_extents.y * 2)
	
	#create signals for enemy pools to emit
	#pool created enemy to add to level
	connect(CONST.SIG_ENEMY_POOL_ADD_NEW, self, "_enemy_created")
	#pool exhausted and over
	connect(CONST.SIG_ENEMY_POOL_FINISHED, self, "_pool_stop_finished")
	
	var enemies_data = UTILS.json_to_dict(CONST.LEVEL_1_ENEMY_PLACEMENT)	
	for area_name in areas_nodes_names:
		var area = get_node(area_name)
		areas_nodes[area_name] = area
		var min_pos = area.get_node("min_stop_pos").get_global_pos()
		var max_pos = area.get_node("max_stop_pos").get_global_pos()
		areas_info[area] = {
			"min_pos": min_pos,
			"max_pos": max_pos,
			"enemy_pool": EnemiesPool.new(self,
			enemies_data[area_name], #enemy data
			min_pos.x, #left X to spawn
			max_pos.x, #right X to spawn
			Vector2(
				ground.nearest_in_bounds(min_pos).y, 
				ground.nearest_in_bounds(max_pos).y
			)) #Y spawn bounds, culled by the ground bounds
		}
		#add enemies pool as child of area to use node-related stuff
		area.add_child(areas_info[area].enemy_pool)
	
	set_process(true)
	
	
func _process(delta):
	for character in get_tree().get_nodes_in_group(CONST.GROUP_CHARS):
		#check ground Z bounds when character not in air
		if (character.feet_ground_y == null):
			var feet_pos = character.feet_pos
			var good_feet_pos = ground.nearest_in_bounds(feet_pos)
			if (feet_pos != good_feet_pos):
				character.set_pos_by_feet(good_feet_pos)
		#always check outer level bounds (except when characters falling
		var good_min = ground.nearest_in_general_bounds(character.min_pos)
		if (good_min.x > character.min_pos.x):
			character.set_pos_by_min(good_min)
		var good_max = ground.nearest_in_general_bounds(character.max_pos)
		if (good_max.x < character.max_pos.x):
			character.set_pos_by_max(good_max)
		#check character in bounds
		if (player_current_bounds_x != null):
			if (character.min_pos.x < player_current_bounds_x.x):
				character.set_pos_by_min(Vector2(player_current_bounds_x.x + 1, character.min_pos.y))
			if (character.max_pos.x > player_current_bounds_x.y):
				character.set_pos_by_max(Vector2(player_current_bounds_x.y - 1, character.max_pos.y))
	#check current stop enemies
	if (current_stop != null and player_current_bounds_x != null):
		var pool = areas_info[current_stop].enemy_pool
		if (pool != null):
			pool._process(delta)


func _pool_stop_finished( pool ):
	for area in areas_info:
		if ( areas_info[area].enemy_pool == pool ):
			#found right area, better clear enemy_pool
			areas_info[area].enemy_pool = null
			print("enemy pool over for %s, unbinding player!" % area)
	player_current_bounds_x = null
	
	
func _enemy_created( enemy_node, global_feet_pos ):
	self.add_child( enemy_node )
	enemy_node.set_pos_by_feet( global_feet_pos )
	enemy_node.set_positions()
	print("Created enemy %s at position %s" % [enemy_node, enemy_node.get_global_pos()])
	
func _enemy_dead( enemy_node ):
	pass
	
func _on_stop_1_body_enter( body ):
	if (body.get_name() == "player"):
		#time to stop player camera and do overhead one
		body.get_node("camera").clear_current()
		set_area_activeness(areas_nodes["stop_1"], true)


func _on_stop_1_body_exit( body ):
	if (body.get_name() == "player"):
		var stop_1 = areas_nodes["stop_1"]
		var pool = areas_info[stop_1].enemy_pool
		#only let my people go if the enemies pool is finished for the stop
		if (pool == null or pool.finished):
			#time to stop overhead camera and do player one
			set_area_activeness(stop_1, false)
			body.get_node("camera").make_current()
			#remove this stop later since its been dealt with
			areas_info.erase(stop_1)
			areas_nodes.erase("stop_1")
			stop_1.queue_free()
		else:
			print("player tried to esacpe stop_1!")


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