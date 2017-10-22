extends Area2D

#quick access to constnats
onready var CONST = get_node("/root/const")
onready var ATTACK_EFFECT_Z = {
	CONST.PLAYER_ANIM_ATTACK_1: 10,
	CONST.PLAYER_ANIM_ATTACK_2: 7,
	CONST.PLAYER_ANIM_ATTACK_JUMP_ASCEND: 12,
 	CONST.PLAYER_ANIM_ATTACK_JUMP_DESCEND: 13
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
		var current_attack = anim.get_current_animation()
		print(str(current_attack) + "|" + str(get_pos()) + "|" + str(enemy.get_pos()))
		if (current_attack != CONST.PLAYER_ANIM_ATTACK_IDLE):
			if (parent.feet_pos.y - ATTACK_EFFECT_Z[current_attack] <= enemy_feet 
			and enemy_feet <= parent.feet_pos.y + ATTACK_EFFECT_Z[current_attack]):
				enemy.getting_hit = true
				enemy.current_state = enemy.STATES.HURTING

