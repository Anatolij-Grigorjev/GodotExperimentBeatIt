extends Node2D


var damage_number

onready var FONT_DEBUG_INFO = preload("res://debug_font.fnt")

func _ready():
	pass
	
func set_vals(num):
	damage_number = num
	
func _draw():
	draw_string(FONT_DEBUG_INFO, Vector2(0, 0),  str(damage_number))

	
func dissappear():
	queue_free()
