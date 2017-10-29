extends Node

var active = false

onready var parent = get_node("../")
onready var player = get_node("../../")

#dictionary for quicker access by id
var area_bodies = {}
var attack_name = "<?>"
var attack_z = 0
var hit_lock = 0.2

func _ready():
	pass

func body_enter( body ):
	if (body == player):
		return
	area_bodies[body.get_name()] = body
	
func body_exit ( body ):
	if (body == player ):
		return
	area_bodies.erase(body.get_name())
	
func process_bodies():
	if (not active):
		return
	for named_body in area_bodies:
		parent.do_attack(area_bodies[named_body], attack_name, attack_z, hit_lock)