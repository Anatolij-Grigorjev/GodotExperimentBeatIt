extends Node

#utility functions
onready var UTILS = get_node("/root/utils")
onready var CONST = get_node("/root/const")
const Z_REDUCTION_COEF = -0.2

var current_extents_x
var current_extents_y

export var feet_pos = Vector2()
export var min_pos = Vector2()
export var max_pos = Vector2()

func _ready():
	#set initial vars
	set_z_as_relative(false)
	set_process(true)	
	
const CIRCLE_COLOR_FEET = Color(1, 0, 1)	
const CIRCLE_COLOR_MIN = Color(0, 1, 0)
const CIRCLE_COLOR_MAX = Color(1, 0, 0)
	
func _draw():
	draw_circle(feet_pos - get_pos(), 10.0, CIRCLE_COLOR_FEET)
	draw_circle(min_pos - get_pos(), 10.0, CIRCLE_COLOR_MIN)
	draw_circle(max_pos - get_pos(), 10.0, CIRCLE_COLOR_MAX)

func _process(delta):
	var pos = get_pos()
	feet_pos = Vector2(pos.x, pos.y + current_extents_y.x)
	min_pos = Vector2(pos.x - current_extents_x.x, pos.y + current_extents_y.x)
	max_pos = Vector2(pos.x + current_extents_x.y, pos.y - current_extents_y.y)
	#update draw call to feet circle (debug feet pos)
	set_z(Z_REDUCTION_COEF * feet_pos.y)
	update()
			
func set_pos_by_feet(feet_pos):
	var pos = Vector2(feet_pos.x, feet_pos.y - current_extents_y.x)
	set_pos(pos)

func set_pos_by_min(min_pos):
	var pos = Vector2(min_pos.x + current_extents_x.x, min_pos.y - current_extents_y.x)
	set_pos(pos)

func set_pos_by_max(max_pos):
	var pos = Vector2(max_pos.x - current_extents_x.y, max_pos.y + current_extents_y.y)
	set_pos(pos)
	
func set_extents(extents_x, extents_y = null):
	if (extents_y == null):
		current_extents_x = Vector2(extents_x.x, extents_x.x)
		current_extents_y = Vector2(extents_x.y, extents_x.y)
	else:
		current_extents_x = extents_x
		current_extents_y = extents_y