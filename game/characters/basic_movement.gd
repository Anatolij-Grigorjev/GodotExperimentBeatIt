extends KinematicBody2D

#utility functions
onready var UTILS = get_node("/root/utils")
onready var CONST = get_node("/root/const")
const Z_REDUCTION_COEF = 0.5
const CIRCLE_COLOR_FEET = Color(1, 0, 1)
const CIRCLE_COLOR_MIN = Color(0, 1, 0)
const CIRCLE_COLOR_MAX = Color(1, 0, 0)
const COLOR_WHITE = Color(1, 1, 1)
onready var FONT_DEBUG_INFO = preload("res://debug_font.fnt")
var attacks_hitboxes
#graivity affecting characters
const GRAVITY = Vector2(0.0, 198)
#main movement vector
var move_vector = Vector2(0, 0)
#should character ignore effects of gravity?
var ignore_G = false  
var feet_ground_y = null #last recorded y position of character before airtime
enum FACING_DIRECTIONS { DIR_LEFT = -1, DIR_RIGHT = 1 }
enum BODY_STATES {
STANDING, WALKING, RUNNING, 
ATTACKING, JUMPING, HURTING, 
FALLING, CATCHING, CATCH_ATTACKING, 
CAUGHT, CAUGHT_HURTING, FALLEN, 
RUN_ATTACKING, DYING, JUMP_ATTACK
}
const STATES_STRINGS = {
	null: "<NONE>",
	0: "STANDING",
	1: "WALKING",
	2: "RUNNING",
	3: "ATTACKING",
	4: "JUMPING",
	5: "HURTING",
	6: "FALLING",
	7: "CATCHING",
	8: "CATCH_ATTACKING",
	9: "CAUGHT",
	10: "CAUGHT_HURTING",
	11: "FALLEN",
	12: "RUN_ATTACKING",
	13: "DYING",
	14: "JUMP_ATTACK"
}

export(int) var current_state = STANDING
export var current_state_ctx = {}

const DISLOGE_KEYS = [ "disloge", "initial_pos"]
var JUMPING_STATES = [ JUMPING, JUMP_ATTACK ]
var HURTING_STATES = [ HURTING, CAUGHT_HURTING ]
var CAUGHT_STATES = [ CAUGHT, CAUGHT_HURTING ]
var FALLING_STATES = [ FALLING, FALLEN, DYING ]
var CATCHING_STATES = [ CATCHING, CATCH_ATTACKING ]


#flag representing hit lock > 0
var getting_hit
#immune to further hits while this is happening
var hit_lock = 0
#flag to check if the character just got hit on current/previous frame
var just_hit = false

var MAX_STUN_POINTS = 100
var MAX_HP = 50 #max hp for this character
var ignore_z = false
var current_stun_points
export var health = 1
export var lying_down_cooldown = 0.2 #time spent lying down, in seconds
export var hurt_pushback_time = 0.15 #time spent pushed back by strong blow
export var armor_coef = 1.0 #additional weigth coefficient to reduce disloge
export var stun_regen_rate = 0.0 #how quikcly does enemy recover from hits, per sec
export var feet_pos = Vector2()
export var min_pos = Vector2()
export var max_pos = Vector2()
export var center_pos = Vector2()
onready var feet_node = get_node("feet")
onready var min_pos_node = get_node("min_pos")
onready var max_pos_node = get_node("max_pos")
#sprites access to set direction
onready var sprite = get_node("sprites")
onready var anim = get_node("anim")

var facing_direction setget set_direction

func _ready():
	#set initial vars
	set_positions()
	reset_state()
	set_z_as_relative(false)
	set_process(true)

func reset_state():
#	print("reset state for %s" % self)
	current_state = STANDING
	getting_hit = false
	ignore_z = false
	ignore_G = false
	current_stun_points = MAX_STUN_POINTS
	current_state_ctx.clear()
	feet_ground_y = null
	
func set_positions():
	feet_pos = feet_node.get_global_pos()
	min_pos = min_pos_node.get_global_pos()
	max_pos = max_pos_node.get_global_pos()
	center_pos = get_global_pos()

func _draw():
	draw_circle(feet_node.get_pos(), 10.0, CIRCLE_COLOR_FEET)
	draw_circle(min_pos_node.get_pos(), 10.0, CIRCLE_COLOR_MIN)
	draw_circle(max_pos_node.get_pos(), 10.0, CIRCLE_COLOR_MAX)
	draw_string(FONT_DEBUG_INFO, Vector2(0, max_pos_node.get_pos().y),  str(get_z()))
	draw_string(FONT_DEBUG_INFO, Vector2(-25, max_pos_node.get_pos().y - 25), STATES_STRINGS[current_state])
	draw_string(FONT_DEBUG_INFO, Vector2(50, max_pos_node.get_pos().y),  "(%s/%s)" % [int(current_stun_points), MAX_STUN_POINTS])
	
func update_hit_stun(delta):
	if (just_hit):
		just_hit = false
	#update hit lock
	getting_hit = hit_lock > 0
	if (getting_hit):
		hit_lock -= delta
	#recover stun points
	if (current_stun_points < MAX_STUN_POINTS and not getting_hit):
		current_stun_points = clamp(current_stun_points + stun_regen_rate * delta, 0.0, MAX_STUN_POINTS)

func update_disloge(delta):
	if (current_state_ctx.has_all(DISLOGE_KEYS)):
		move_vector += current_state_ctx.disloge
		#check if disloge distance achieved
		var got_there = disloged_enough()
		if (got_there):
			for key in DISLOGE_KEYS:
				current_state_ctx.erase(key)
				
func disloged_enough():
	if (current_state_ctx.has_all(DISLOGE_KEYS)):
		#checking y disloge is good for falling
		if (current_state == FALLING):
			#did the character go high enough into the air from the disloge
			var y_ok = abs(center_pos.y - current_state_ctx.initial_pos.y) >= abs(current_state_ctx.disloge.y)
			return y_ok
		#for other situations need to check x disloge
		else:
			var x_ok = abs(center_pos.x - current_state_ctx.initial_pos.x) >= abs(current_state_ctx.disloge.x)
			return x_ok
	else:
		return true

func update_hurt_states(delta):
	if (current_state == FALLING):
		#fly till we reach point of takeoff
		if (ignore_G):
			ignore_G = not disloged_enough()
		else:
			if (current_state_ctx.fall_start_y < feet_pos.y):
				current_state = FALLEN
				feet_ground_y = null
				ignore_z = false
				current_state_ctx.lying_cooldown = lying_down_cooldown
		return
	if (current_state == FALLEN):
		if (health <= 0):
			current_state = DYING
			do_death()
			return
		if (current_state_ctx.lying_cooldown > 0):
			current_state_ctx.lying_cooldown -= delta
		#enough lying down on the job, get up and do something
		else:
			reset_state()
		return
	#check hurting states
	if (current_state in HURTING_STATES):
		#currently hurting
		if (!getting_hit and !anim.is_playing()):
			#finished hurting and not being hurt no more,
			#so get back to standing 
			if (current_state == HURTING):
				reset_state()
			else:
				current_state = CAUGHT
		return
		
func do_death():
	print("[WARN] Function do_death not overriden in %s!" % self)

func _process(delta):
	set_positions()
	
	#ignore z while character in air
	if (feet_ground_y != null):
		ignore_z = true
	if (not ignore_z):
		set_z(Z_REDUCTION_COEF * feet_pos.y)
	#calculate G force if its not ignored 
	if (not ignore_G and feet_ground_y != null):
		var move_down = GRAVITY
		#halfspeed down when attacking
		if (current_state == ATTACKING):
			move_down.y /= 1.1
		move_vector.y += move_down.y
		
	update_hit_stun(delta)
	update_disloge(delta)
	update_hurt_states(delta)
	#do update for draw calls
	update()


func set_pos_by_feet(feet_pos):
	var pos = Vector2(feet_pos.x, feet_pos.y - feet_node.get_pos().y)
	set_pos(pos)

func set_pos_by_min(min_pos):
	var min_pos_local = min_pos_node.get_pos()
	#technically should be + min local x, but its likely negative
	var pos = Vector2(min_pos.x - min_pos_local.x, min_pos.y - min_pos_local.y)
	set_pos(pos)

func set_pos_by_max(max_pos):
	var max_pos_local = max_pos_node.get_pos()
	#technically should be + min local y, but its likely negative
	var pos = Vector2(max_pos.x - max_pos_local.x, max_pos.y - max_pos_local.y)
	set_pos(pos)
	
func set_direction(new_dir):
	facing_direction = new_dir
	sprite.set_scale(Vector2(new_dir, sprite.get_scale().y))
	
func state_for_stun():
	#always fall when dead
	if (health <= 0):
		return FALLING
	if (current_state in JUMPING_STATES):
		return FALLING
	if (MAX_STUN_POINTS / 2 <= current_stun_points and current_stun_points <= MAX_STUN_POINTS):
		return STANDING
	elif (1 <= current_stun_points and current_stun_points < MAX_STUN_POINTS / 2):
		return HURTING
	else:
		return FALLING
	
func get_hit(attacker, attack_info):
	if (attacks_hitboxes != null):
		attacks_hitboxes.reset_attacks()
	else:
		print("No attack hitboxes set on %s!" % self)
	getting_hit = true
	just_hit = true
	hit_lock = attack_info.hit_lock 
	current_stun_points -= attack_info.attack_stun
	set_health(health - attack_info.attack_power)
	#check prev state later in method
	var prev_state = current_state
	#state was caught or not
	current_state = state_for_stun() if !(prev_state in CAUGHT_STATES) else CAUGHT_HURTING 
	if (attack_info.disloge_vector != CONST.VECTOR2_ZERO):
		var opponent = attacker
		#strip sign of X, assign our own
		var disloge = Vector2(attack_info.disloge_vector.x, attack_info.disloge_vector.y)
		#hit character fall direction depends on where the hitter was facing	
		disloge.x *= sign(opponent.sprite.get_scale().x)
		#setup pushback
		current_state_ctx.disloge = disloge / armor_coef
		current_state_ctx.initial_pos = center_pos
		
		if (current_state == FALLING):
			#was already hurting when this attack hit, 
			#fly back with full force
			ignore_z = true
			#fall animation direction is independant of actual fall direction
			#depends on what direction opponent was facing in relation
			#to character
			if (UTILS.sprites_facing(opponent.sprite, sprite)):
				current_state_ctx.fall_direction = 1 
			else:
				current_state_ctx.fall_direction = -1
			current_state_ctx.fall_start_y = feet_pos.y
			#ignore gravity and fly through the air while we can
			ignore_G = true
			feet_ground_y = feet_pos.y
		else:
			#was not yet hurt when attack hit, 
			#push back half distance and start hurting
			current_state_ctx.disloge = Vector2(
				current_state_ctx.disloge.x / 2, 0)

func set_health( health ):
	self.health = health
