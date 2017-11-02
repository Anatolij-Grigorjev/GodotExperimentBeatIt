extends Node

var active = false

onready var parent = get_node("../")
onready var player = get_node("../../")

#dictionary for quicker access by id
var area_bodies = {}

var attack_info = {
	#name of attack
	attack_name = "<?>",
	#width of attack effectivness on the field
	attack_z = 0,
	#how long does hte post-attack invulnerability last on enemy
	hit_lock = 0.2,
	#force vector to fall enemy when hit by attack
	disloge_vector = Vector2(0,0)
}

func _ready():
	pass
	
func dump():
	print(attack_info)

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
		parent.do_attack(area_bodies[named_body], attack_info)