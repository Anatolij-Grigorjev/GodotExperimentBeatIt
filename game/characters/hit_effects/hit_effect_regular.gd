extends Node2D


onready var dmg_numbers = preload("dmg_numbers.tscn")

func _ready():
	pass
	
func set_vals(num, victim):
	var dmg = dmg_numbers.instance()
	#attach to scene
	victim.add_child(dmg)
	dmg.set_pos(get_pos())
	dmg.get_node("dmg_label").set_text(str(round(num)))
