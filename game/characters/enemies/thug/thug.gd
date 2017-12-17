extends "../enemy.gd"

var movement = {}
onready var hit_effect = preload("res://characters/hit_effects/hit_effect_regular.tscn")

func _ready():
	#init enemy variables
	decision_interval = rand_range(0.75, 1.1) 
	scan_distance = rand_range(175, 275) 
	attack_distance = rand_range(50, 85)
	aggressiveness = rand_range(0.5, 0.70)
	movement_speed = Vector2(rand_range(100, 150), rand_range(40, 50))
	lying_down_cooldown = 0.6
	hurt_pushback_time = 0.2
	stun_regen_rate = rand_range(10, 20)
	attacks_hitboxes = get_node("sprites/attack_hitboxes")
	attacks = [
		CONST.THUG_ANIM_ATTACK_1,
		CONST.THUG_ANIM_ATTACK_2,
	]
	movement.jumping = false
	current_anim = CONST.THUG_ANIM_IDLE
	anim.play(current_anim)
	MAX_HP = rand_range(200, 300)
	._ready()
	
func _process(delta):
	._process(delta)
	
func setup_body_slam():

	#attack specifics
	body_area.attack_info.attack_name = "body_area"
	body_area.attack_info.attack_stun = 100
	body_area.attack_info.attack_power = 20
	body_area.attack_info.attack_z = 3
	body_area.attack_info.hit_lock = 0.5
	body_area.attack_info.disloge_vector = Vector2(150,-25)
	
	if (attacks_hitboxes != null):
		attacks_hitboxes.attacks_hitboxes.append(body_area)
		print("Added %s to attacks list!" % body_area.attack_info)

	
const CIRCLE_COLOR_PAIN = Color(1, 1, 1)
func _draw():
	._draw()

	#draw_string(FONT_DEBUG_INFO, Vector2(-50, max_pos_node.get_pos().y), str(health))
	if (current_state == HURTING):
		draw_circle(sprite.get_pos(), 10.0, CIRCLE_COLOR_PAIN)
	
func change_anim():
	if (current_state == STANDING):
		current_anim = CONST.THUG_ANIM_IDLE
	elif (current_state == WALKING):
		current_anim = CONST.THUG_ANIM_MOVE
	elif (current_state == ATTACKING):
		current_anim = attacks[current_state_ctx.attack]
		
	elif (current_state == CAUGHT):
		current_anim = CONST.THUG_ANIM_CAUGHT
	elif (current_state == CAUGHT_HURTING):
		current_anim = CONST.THUG_ANIM_CAUGHT_HURT
		
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
			
	elif (current_state == FALLEN):
		if current_state_ctx.fall_direction > 0:
			current_anim = CONST.THUG_ANIM_ON_BACK
		else:
			current_anim = CONST.THUG_ANIM_ON_BELLY
	elif (current_state == DYING):
		if (!(current_anim in [CONST.THUG_ANIM_ON_BACK, CONST.THUG_ANIM_ON_BELLY])):
			#try evaluating again
			current_state = FALLEN
			change_anim()
			current_state = DYING
		#dying animation name is based on fallen animation name (on belly or on back)
		current_anim = "thug_death_" + current_anim.right("thug_fall_".length())

func do_death():
	pass
