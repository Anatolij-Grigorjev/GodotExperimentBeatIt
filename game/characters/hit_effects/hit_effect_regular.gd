extends Node2D


onready var dmg_numbers = preload("dmg_numbers.tscn")
onready var level = get_node("/root/level")

func _ready():
	pass
	
func set_vals(num):
	var dmg = dmg_numbers.instance()
	#attach to scene
	level.add_child(dmg)
	dmg.set_global_pos(get_global_pos())
	dmg.prepare_animation(str(round(num)))

