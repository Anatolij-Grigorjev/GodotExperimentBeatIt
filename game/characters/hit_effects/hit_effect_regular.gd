extends Node2D


var damage_number

onready var label = get_node("label")

func _ready():
	pass
	
func set_vals(num):
	damage_number = num
	label.set_text(str(round(num)))

	
func dissappear():
	queue_free()
