extends Node

#utility functions
onready var UTILS = get_node("/root/utils")
onready var CONST = get_node("/root/const")

var current_extents

export var feet_pos = Vector2()
export var min_pos = Vector2()
export var max_pos = Vector2()

func _ready():
	set_process(true)


func _process(delta):
	var pos = get_pos()
	feet_pos = Vector2(pos.x, pos.y + current_extents.y)
	min_pos = Vector2(pos.x - current_extents.x, pos.y + current_extents.y)
	max_pos = Vector2(pos.x + current_extents.x, pos.y - current_extents.y)
			
func set_pos_by_feet(feet_pos):
	var pos = Vector2(feet_pos.x, feet_pos.y - current_extents.y)
	set_pos(pos)

func set_pos_by_min(min_pos):
	var pos = Vector2(min_pos.x + current_extents.x, min_pos.y - current_extents.y)
	set_pos(pos)

func set_pos_by_max(max_pos):
	var pos = Vector2(max_pos.x - current_extents.x, max_pos.y + current_extents.y)
	set_pos(pos)