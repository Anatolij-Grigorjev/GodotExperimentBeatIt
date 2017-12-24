extends Node

onready var healthbar = get_node("healthbar")
onready var max_hp_lbl = get_node("labels/max_hp")
onready var curr_hp_lbl = get_node("labels/current_hp")

func _ready():
	healthbar.set_min( 0 )
	curr_hp_lbl.set_text(str(0))
	max_hp_lbl.set_text(str(0))


func _set_max_hp( max_hp ):
	healthbar.set_max( max_hp )
	max_hp_lbl.set_text( str(round(max_hp)) )

func _set_hp( hp ):
	healthbar.set_value( hp )
	curr_hp_lbl.set_text( str(round(hp)) )