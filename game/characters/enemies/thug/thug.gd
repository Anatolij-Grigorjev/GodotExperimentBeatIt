extends "../enemy.gd"


onready var sprite = get_node("movement/sprite")
var movement = {}
onready var hit_effect = preload("res://characters/hit_effects/hit_effect_regular.tscn")

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
	._ready()
	
func _process(delta):
	._process(delta)
	
	
func _draw():
	._draw()
	
func change_anim():
	if (current_state == STANDING):
		current_anim = CONST.THUG_ANIM_IDLE
	elif (current_state == MOVING):
		current_anim = CONST.THUG_ANIM_MOVE
	elif (current_state == ATTACKING):
		current_anim = attacks[current_state_ctx.attack]
	elif (current_state == HURTING):
		current_anim = CONST.THUG_ANIM_HURTING
		#thug was already hurting, lets restart the animation
		if (anim.is_playing() and 
		anim.get_current_animation() == current_anim and
		just_hit):
			anim.play(current_anim)
	elif (current_state == FALLING):
		if current_state_ctx.fall_direction > 0:
			current_anim = CONST.THUG_ANIM_FALLING_FWD 
		else: 
			current_anim = CONST.THUG_ANIM_FALLING_BCK

func take_action(delta):
	#custom thug attack actions
	.take_action(delta)
	
func get_hit(hit_lock):
	.get_hit(hit_lock)
	hit_effect.instance()
	
