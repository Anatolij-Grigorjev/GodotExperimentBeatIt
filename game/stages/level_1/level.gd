extends Node

onready var CONST = get_node("/root/const")

onready var player = get_node("player")
onready var ground = get_node("ground")

func _ready():
	set_process(true)
	
func _process(delta):
	
	if (!player.movement.jumping):
		var feet_pos = player.feet_pos
		var good_feet_pos = ground.nearest_in_bounds(feet_pos)
		if (feet_pos != good_feet_pos):
			player.set_pos_by_feet(good_feet_pos)
	var good_min = ground.nearest_in_general_bounds(player.min_pos)
	if (good_min.x > player.min_pos.x):
		player.set_pos_by_min(good_min)
	var good_max = ground.nearest_in_general_bounds(player.max_pos)
	if (good_max.x < player.max_pos.x):
		player.set_pos_by_max(good_max)
