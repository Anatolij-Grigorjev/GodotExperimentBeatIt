extends "../enemy.gd"


onready var sprite = get_node("movement/sprite")
var movement = {}

func _ready():
	#init enemy variables
	decision_interval = 0.5 
	scan_distance = 300 
	attack_distance = 50
	aggressiveness = 0.70 
	movement_speed = Vector2(150, 50)
	attacks = [
		CONST.THUG_ANIM_ATTACK_1
	]
	movement.jumping = false
	current_anim = CONST.THUG_ANIM_IDLE
	anim.play(current_anim)	
	#init movement variables
	set_extents(UTILS.get_sprite_extents(sprite))
	._ready()
	
func _draw():
	if (getting_hit):
		draw_circle(Vector2(0,0), 10.0, Color(1, 1, 1))
	
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

func _on_thug_body_enter( body ):
	if (body.is_in_group(CONST.GROUP_PLAYER_SWORD)):
		body.process_sword_hit(self)
