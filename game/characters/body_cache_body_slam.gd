extends Node

var active = false

onready var attacks_processor = get_node("../sprites/attack_hitboxes")
onready var owner = get_node("../")

#dictionary instead of list for quicker access by id
var area_bodies = {}

var attacker = null

var attack_info = {
	#name of attack
	attack_name = "<?>",
	#override for global setting of what group to target with attacks
	target_group = "enemies",
	#how many stun points attack hits for
	attack_stun = 0,
	#how many HP does this attack take in damage
	attack_power = 1,
	#width of attack effectivness on the field
	attack_z = 0,
	#how long does the post-attack invulnerability last on enemy
	hit_lock = 0.2,
	#position of hit spark effect as a 2D vector, null means no spark
	hit_location = null,
	#force vector to move enemy when hit by attack
	disloge_vector = Vector2(0,0),
}

func _ready():
	pass
	
func dump():
	print(attack_info)

func body_enter( body ):
	if (body == owner):
		return
	if (attacker != null and attacker == body):
		return
	area_bodies[body.get_name()] = body
	
func body_exit ( body ):
	if (body == owner ):
		return
	if (attacker != null and attacker == body):
		return
	area_bodies.erase(body.get_name())
	
func process_bodies():
	if (not active):
		return
	if (attacker != null and area_bodies.has(attacker.get_name())):
		area_bodies.erase(attacker.get_name())
	for named_body in area_bodies:
		attacks_processor.do_attack(area_bodies[named_body], attack_info)

func toggle(active = true):
	self.active = active