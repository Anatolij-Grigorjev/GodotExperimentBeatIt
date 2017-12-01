extends "../basic_movement.gd"

const MAX_STUN_POINTS = 100

var current_stun_points
var current_decision_wait
var current_state_ctx = {}
var attacks = []
var current_anim
var getting_hit
#amount of time enemy is actively getting hit
#immune to further hits while this is happening
var hit_lock = 0
#flag to check if the enemy just got hit on the previous frame
#gets consumed on next update
var just_hit = false

#enemy pool index, should be updated before death
var pool_idx = -1

onready var anim = get_node("anim")
var player
const DISLOGE_KEYS = [ "disloge", "initial_pos"]
var HURTING_STATES = [ HURTING, CAUGHT_HURTING ]
var CAUGHT_STATES = [ CAUGHT, CAUGHT_HURTING ]
#main defaults for enemies on things
export var decision_interval = 2.5 #in seconds
export var scan_distance = 350 # in pixels, to either side
export var attack_distance = 50 #in pixels, either side
export var aggressiveness = 0.75 # in percentiles
export var lying_down_cooldown = 0.2 #time spent lying down, in seconds
export var hurt_pushback_time = 0.15 #tiem spent pushed back by strong blow
export var movement_speed = Vector2(150, 50)
export var armor_coef = 1.0 #additional weigth coefficient to reduce disloge
export var stun_regen_rate = 0.0 #how quikcly does enemy recover from hits


func _ready():
	reset_state()
	getting_hit = false
	just_hit = false
	current_stun_points = MAX_STUN_POINTS
	player = get_tree().get_root().find_node("player", true, false)
	._ready()
	
func _process(delta):
	move_vector = CONST.VECTOR2_ZERO
	if (player != null):
		var old_state = current_state
		change_state(delta)
		take_action(delta)
	
		change_anim()
		if (current_anim != anim.get_current_animation()):
			anim.play(current_anim)
	
	if (current_state_ctx.has_all(DISLOGE_KEYS)):
		move_vector += current_state_ctx.disloge
		#check if disloge distance achieved
		var got_there = disloged_enough()
		if (got_there):
			for key in DISLOGE_KEYS:
				current_state_ctx.erase(key)
	
	if (just_hit):
		just_hit = false
	
	#recover stun points
	if (current_stun_points < MAX_STUN_POINTS and not getting_hit):
		current_stun_points = clamp(current_stun_points + stun_regen_rate, 0.0, MAX_STUN_POINTS)	
	
	#update hit lock
	getting_hit = hit_lock > 0
	if (getting_hit):
		hit_lock -= delta
	
	._process(delta)
	
	#integrate new position
	var new_pos = get_pos() + (move_vector * delta)
	set_pos(new_pos)

func change_anim():
	pass
	
func disloged_enough():
	if (current_state_ctx.has_all(DISLOGE_KEYS)):
		#checking y disloge is good for falling
		if (current_state == FALLING):
			#did the enemy go high enough into the air from the disloge
			var y_ok = abs(center_pos.y - current_state_ctx.initial_pos.y) >= abs(current_state_ctx.disloge.y)
			return y_ok
		#for other situations need to check x disloge
		else:
			var x_ok = abs(center_pos.x - current_state_ctx.initial_pos.x) >= abs(current_state_ctx.disloge.x)
			return x_ok
	else:
		return true
	
func reset_state(action_wait = decision_interval):
	current_state = STANDING
	getting_hit = false
	ignore_z = false
	ignore_G = false
	current_stun_points = MAX_STUN_POINTS
	current_state_ctx.clear()
	feet_ground_y = null
	current_decision_wait = action_wait
	
func change_state(delta):
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
		if (current_state_ctx.lying_cooldown > 0):
			current_state_ctx.lying_cooldown -= delta
	#enough lying down on the job, get up and do something
		else:
			reset_state()
		return
	#some states are not meant to make decisions
	if (current_state in HURTING_STATES):
		#currently hurting
		if (!getting_hit and !anim.is_playing()):
			#finished hurting and not being hurt no more,
			#so get back to standing and 
			#make another decision on the next frame
			if (current_state == HURTING):
				reset_state(0)
			else:
				current_state = CAUGHT
		return
	if (current_state == CAUGHT):
		return
	#make deiscions
	current_decision_wait -= delta

	if (current_decision_wait < 0):
		#make decision,
		#due to upper if, unlikely to be HURTING here
		var distance = player.get_pos() - get_pos()
		if (current_state == STANDING):
			#scan area for player
			if (abs(distance.x) < scan_distance):
				#player spotted, lets check if we care
				if (randf() < aggressiveness):
					if (abs(distance.x) < attack_distance):
						set_attack_state(distance)
					else:
						current_state = WALKING
						current_state_ctx.direction = distance.normalized()
			
			pass
		elif (current_state == WALKING):
			
			if (abs(distance.x) < attack_distance):
				set_attack_state(distance)
				#lost enemy
			elif (abs(distance.x) > scan_distance):
				current_state = STANDING
				current_state_ctx = {}
		elif(current_state == ATTACKING):
			if (anim.get_current_animation() in attacks and !anim.is_playing()):
				#attack finished, back to standing
				current_state = STANDING
			pass
		else:
			current_state = STANDING
		current_decision_wait = decision_interval
			
func take_action(delta):
	#take action based on elected state
	if (current_state == WALKING):
		set_pos(get_pos() + (current_state_ctx.direction * movement_speed * delta))
		print(current_state_ctx.direction)
		if (current_state_ctx.direction.x != 0):
			set_direction(sign(current_state_ctx.direction.x))

#default implementation for enemy is to pick a random attack
func set_attack_state(distance):
	set_random_attack_state(distance)

func set_random_attack_state(distance):
	current_state = ATTACKING
	current_state_ctx.direction = distance.normalized()
	current_state_ctx.attack = randi() % attacks.size()
	
func dying():
	emit_signal(CONST.SIG_ENEMY_DEATH, pool_idx)
	queue_free()

func state_for_stun():
	if (MAX_STUN_POINTS / 2 <= current_stun_points and current_stun_points <= MAX_STUN_POINTS):
		return STANDING
	elif (1 <= current_stun_points and current_stun_points < MAX_STUN_POINTS / 2):
		return HURTING
	else:
		return FALLING
	
func get_hit(attack_info):
	getting_hit = true
	just_hit = true
	hit_lock = attack_info.hit_lock 
	current_stun_points -= attack_info.attack_stun
	#check prev state later in method
	var prev_state = current_state
	#state was caught or not
	current_state = state_for_stun() if !(prev_state in CAUGHT_STATES) else CAUGHT_HURTING 
	if (attack_info.disloge_vector != CONST.VECTOR2_ZERO):
		#strip sign of X, assign our own
		var disloge = Vector2(attack_info.disloge_vector.x, attack_info.disloge_vector.y)
		#hit enemy fall direction depends on where the player was facing	
		disloge.x *= sign(player.sprite.get_scale().x)
		#setup pushback
		current_state_ctx.disloge = disloge / armor_coef
		current_state_ctx.initial_pos = center_pos
		
		if (current_state == FALLING):
			#was already hurting when this attack hit, 
			#fly back with full force
			ignore_z = true
			#fall animation direction is independant of actual fall direction
			#depends on what direction player was facing in relation
			#to enemy
			if (UTILS.sprites_facing(player.sprite, sprite)):
				current_state_ctx.fall_direction = 1 
			else:
				current_state_ctx.fall_direction = -1
			current_state_ctx.fall_start_y = feet_pos.y
			#ignore gravity and fly through the air while we can
			ignore_G = true
			feet_ground_y = feet_pos.y
		else:
			#was not yet hurt when attack hit, 
			#push back half idstance and start hurting
			current_state_ctx.disloge = Vector2(
				current_state_ctx.disloge.x / 2, 0)