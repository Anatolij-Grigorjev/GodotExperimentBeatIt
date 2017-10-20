extends "../enemy.gd"


onready var sprite = get_node("sprite")

func _ready():
	#init enemy variables
	decision_interval = 2.5 
	scan_distance = 300 
	attack_distance = 50
	aggressiveness = 0.70 
	movement_speed = Vector2(175, 50)
	attacks = [
		CONST.THUG_ANIM_ATTACK_1
	]
	current_anim = CONST.THUG_ANIM_IDLE
	
	#init movement variables
	current_extents = UTILS.get_sprite_extents(sprite)
	._ready()
	
	
func change_anim():
	if (current_state == STANDING):
		current_anim = CONST.THUG_ANIM_IDLE
	elif (current_state == MOVING):
		current_anim = CONST.THUG_ANIM_MOVE
	elif (current_state == ATTACKING):
		current_anim = attacks[current_state_ctx.attack]
	elif (current_state == HURTING):
		current_anim = CONST.THUG_ANIM_HURTING
		
func take_action(delta):
	#custom thug attack actions
	
	
	.take_action(delta)