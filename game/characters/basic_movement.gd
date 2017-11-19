extends KinematicBody2D

#utility functions
onready var UTILS = get_node("/root/utils")
onready var CONST = get_node("/root/const")
const Z_REDUCTION_COEF = 0.5
const CIRCLE_COLOR_FEET = Color(1, 0, 1)	
const CIRCLE_COLOR_MIN = Color(0, 1, 0)
const CIRCLE_COLOR_MAX = Color(1, 0, 0)
onready var FONT_DEBUG_INFO = preload("res://debug_font.fnt")

#graivity affecting characters
const GRAVITY = Vector2(0.0, 198)
#main movement vector
var move_vector = Vector2(0, 0)
#should character ignore effects of gravity?
var ignore_G = false  
var feet_ground_y = null #last recorded y position of character before airtime

enum BODY_STATES {
STANDING, WALKING, RUNNING, 
ATTACKING, JUMPING, HURTING, 
FALLING, CATCHING, CAUGHT, 
CAUGHT_HURTING, FALLEN
}
const STATES_STRINGS = {
	null: "<NONE>",
	0: "STANDING",
	1: "WALKING",
	2: "RUNNING",
	3: "ATTACKING",
	4: "JUMPING",
	5: "HURTING",
	6: "FALLING",
	7: "CATCHING",
	8: "CAUGHT",
	9: "CAUGHT_HURTING",
	10: "FALLEN"
}

export(int) var current_state = STANDING

var ignore_z = false
export var feet_pos = Vector2()
export var min_pos = Vector2()
export var max_pos = Vector2()
onready var feet_node = get_node("feet")
onready var min_pos_node = get_node("min_pos")
onready var max_pos_node = get_node("max_pos")

func _ready():
	#set initial vars
	set_positions()
	set_z_as_relative(false)
	set_process(true)	
	
func set_positions():
	feet_pos = feet_node.get_global_pos()
	min_pos = min_pos_node.get_global_pos()
	max_pos = max_pos_node.get_global_pos()

func _draw():
	draw_circle(feet_node.get_pos(), 10.0, CIRCLE_COLOR_FEET)
	draw_circle(min_pos_node.get_pos(), 10.0, CIRCLE_COLOR_MIN)
	draw_circle(max_pos_node.get_pos(), 10.0, CIRCLE_COLOR_MAX)
	draw_string(FONT_DEBUG_INFO, Vector2(0, max_pos_node.get_pos().y),  str(get_z()))
	draw_string(FONT_DEBUG_INFO, Vector2(-25, max_pos_node.get_pos().y - 25), STATES_STRINGS[current_state])

func _process(delta):
	set_positions()
	
	#ignore z while character in air
	if (feet_ground_y != null):
		ignore_z = true
	if (not ignore_z):
		set_z(Z_REDUCTION_COEF * feet_pos.y)
	#calculate G force if its not ignored 
	if (not ignore_G and feet_ground_y != null):
		var move_down = GRAVITY
		#halfspeed down when attacking
		if (current_state == ATTACKING):
			move_down.y /= 2
		move_vector.y += move_down.y
	#do update for draw calls
	update()


func set_pos_by_feet(feet_pos):
	var pos = Vector2(feet_pos.x, feet_pos.y - feet_node.get_pos().y)
	set_pos(pos)

func set_pos_by_min(min_pos):
	var min_pos_local = min_pos_node.get_pos()
	#technically should be + min local x, but its likely negative
	var pos = Vector2(min_pos.x - min_pos_local.x, min_pos.y - min_pos_local.y)
	set_pos(pos)

func set_pos_by_max(max_pos):
	var max_pos_local = max_pos_node.get_pos()
	#technically should be + min local y, but its likely negative
	var pos = Vector2(max_pos.x - max_pos_local.x, max_pos.y - max_pos_local.y)
	set_pos(pos)