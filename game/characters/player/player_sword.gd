extends Area2D

#quick access to constnats
onready var CONST = get_node("/root/const")
onready var ATTACK_EFFECT_Z = {
	CONST.PLAYER_ANIM_ATTACK_1: 25,
	CONST.PLAYER_ANIM_ATTACK_2: 20,
	CONST.PLAYER_ANIM_ATTACK_JUMP_ASCEND: 30,
 	CONST.PLAYER_ANIM_ATTACK_JUMP_DESCEND: 35
}
#access to main character node
onready var parent = get_node("../../")
onready var anim = get_node("../anim")

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass


func _on_sword_area_enter( area ):
	#handle an enemy getting hit
	if (area.is_in_group(CONST.GROUP_ENEMIES)):
		var enemy = area
		#lower center of enemy to see if they in attack range
		var enemy_feet = enemy.feet_pos
		var diff = abs(parent.feet_pos.y - enemy_feet.y)
		var current_attack = anim.get_current_animation()
		print(str(current_attack) + "|" + str(parent.feet_pos) + "|" + str(enemy.feet_pos))
		if (current_attack != CONST.PLAYER_ANIM_ATTACK_IDLE):
			if (diff < ATTACK_EFFECT_Z[current_attack]):
				print("attack hit true! Hitting: " + str(enemy))
				enemy.getting_hit = true
				enemy.current_state = enemy.STATES.HURTING
			else:
				print("attack went wide! Difference: " + 
				str(diff) + 
				"|Required: " + str(ATTACK_EFFECT_Z[current_attack]))

