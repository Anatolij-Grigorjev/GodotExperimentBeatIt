extends Node

onready var healthbar = get_node("healthbar")

func _ready():
	healthbar.set_min( 0 )


func _set_max_hp( max_hp ):
	healthbar.set_max( max_hp )

func _set_hp( hp ):
	healthbar.set_value( hp )