extends Node

var active = false

onready var parent = get_node("../")
onready var owner = get_node("../../../")

#dictionary instead of list for quicker access by id
var area_bodies = {}

enum ATTACK_TYPES {
	GROUND_ATTACK = 0,
	JUMP_ATTACK = 1,
	CATCH_ATTACK = 2,
	THROW_ATTACK = 3
}

var attack_info = {
	#name of attack
	attack_name = "<?>",
	#how many stun points attack hits for
	attack_stun = 0,
	#how many HP does this attack take in damage
	attack_power = 1,
	#width of attack effectivness on the field
	attack_z = 0,
	#how long does the post-attack invulnerability last on enemy
	hit_lock = 0.2,
	#force vector to move enemy when hit by attack
	disloge_vector = Vector2(0,0),
	#helper components of disloge_vector for reading from file
	disloge_x = null,
	disloge_y = null,
	#attack type, for later use
	attack_type = GROUND_ATTACK
}

func _ready():
	pass
	
func dump():
	print(attack_info)

func body_enter( body ):
	if (body == owner):
		return
	area_bodies[body.get_name()] = body
	
func body_exit ( body ):
	if (body == owner ):
		return
	area_bodies.erase(body.get_name())
	
func process_bodies():
	if (not active):
		return
	for named_body in area_bodies:
		parent.do_attack(area_bodies[named_body], attack_info)

func toggle(active = true):
	self.active = active