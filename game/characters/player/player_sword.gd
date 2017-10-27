extends Area2D

#quick access to constnats
onready var CONST = get_node("/root/const")
onready var ATTACK_EFFECT_Z = {
	CONST.PLAYER_ANIM_ATTACK_1: 3,
	CONST.PLAYER_ANIM_ATTACK_2: 2,
	CONST.PLAYER_ANIM_ATTACK_JUMP_ASCEND: 4,
 	CONST.PLAYER_ANIM_ATTACK_JUMP_DESCEND: 5
}
#access to main character node
onready var parent = get_node("../")
onready var anim = get_node("../player_attack/anim")

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass


func _on_sword_body_enter( body ):
	#handle an enemy getting hit
	if (body.is_in_group(CONST.GROUP_ENEMIES)):
		var enemy = body
		#cant hit an enemy twice while they are being hit
		if (enemy.getting_hit):
			return
		#lower center of enemy to see if they in attack range
		var enemy_z = enemy.get_z()
		var diff = abs(parent.get_z() - enemy_z)
		var current_attack = anim.get_current_animation()
		print(str(current_attack) + "|" + str(parent.get_z()) + "|" + str(enemy_z))
		if (current_attack != CONST.PLAYER_ANIM_ATTACK_IDLE):
			if (diff < ATTACK_EFFECT_Z[current_attack]):
				print("attack hit true! Hitting: " + str(enemy))
				enemy.getting_hit = true
				enemy.hit_frames = 5 
				enemy.current_state = enemy.STATES.HURTING
			else:
				print("attack went wide! Difference: " + 
				str(diff) + 
				"|Required: " + str(ATTACK_EFFECT_Z[current_attack]))
