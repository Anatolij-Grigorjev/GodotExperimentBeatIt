extends "../basic_movement.gd"

var current_decision_wait
var current_state_ctx = {}
var attacks = []
var current_anim
var getting_hit
#amount of time enemy is actively getting hit
#immune to further hits while this is happening
var hit_lock
#flag to check if the enemy just got hit on the previous frame
#gets consumed on next update
var just_hit = false

onready var anim = get_node("anim")
onready var sprite = get_node("sprite")
var player

#main defaults for enemies on things
export var decision_interval = 2.5 #in seconds
export var scan_distance = 350 # in pixels, to either side
export var attack_distance = 50 #in pixels, either side
export var aggressiveness = 0.75 # in percentiles
export var lying_down_cooldown = 0.2 #time spent lying down, in seconds
export var movement_speed = Vector2(150, 50)


func _ready():
	reset_state()
	getting_hit = false
	just_hit = false
	player = get_tree().get_root().find_node("player", true, false)
	._ready()
	
func _process(delta):
	if (player != null):
		var old_state = current_state
		change_state(delta)
		take_action(delta)
	
		change_anim()
		if (current_anim != anim.get_current_animation()):
			anim.play(current_anim)
	
	if (just_hit):
		just_hit = false
	#process movement limitations on level
	._process(delta)

func change_anim():
	pass
	
func reset_state(action_wait = decision_interval):
	current_state = STANDING
	current_state_ctx.clear()
	current_decision_wait = action_wait
	
func change_state(delta):
	if (current_state == FALLING):
		#fly till we reach point of takeoff
		if (current_state_ctx.fall_start_y < feet_pos.y):
			current_state = FALLEN
			current_state_ctx.lying_cooldown = lying_down_cooldown
	if (current_state == FALLEN):
		if (current_state_ctx.lying_cooldown > 0):
			current_state_ctx.lying_cooldown -= delta
	#enough lying down on the job, get up and do something
		else:
			reset_state()
	#some states are not meant to make decisions
	if (current_state == HURTING):
		getting_hit = hit_lock > 0
		if (getting_hit):
			hit_lock -= delta
		#currently hurting
		if (!getting_hit and !anim.is_playing()):
			#finished hurting and not being hurt no more,
			#so get back to standing and 
			#make another decision on the next frame
			reset_state(0)
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
						set_random_attack_state(distance)
					else:
						current_state = WALKING
						current_state_ctx.direction = distance.normalized()
			
			pass
		elif (current_state == WALKING):
			
			if (abs(distance.x) < attack_distance):
				set_random_attack_state(distance)
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
		if (current_state_ctx.direction.x < 0):
			sprite.set_scale(Vector2(-1.0, 1.0))
		elif (current_state_ctx.direction.x > 0):
			sprite.set_scale(Vector2(1.0, 1.0))
			
func set_random_attack_state(distance):
	current_state = ATTACKING
	current_state_ctx.direction = distance.normalized()
	current_state_ctx.attack = randi() % attacks.size()
	
func get_hit(attack_info):
	getting_hit = true
	just_hit = true
	hit_lock = attack_info.hit_lock 
	current_state = HURTING
	if (attack_info.disloge_vector != CONST.VECTOR2_ZERO):
		#strip sign of X, assign our own
		var disloge = Vector2(abs(attack_info.disloge_vector.x), attack_info.disloge_vector.y)
		#make it a hit in the back if enemy and player
		# were facing same the same direction, 
		#hit in the front otherwise
		if (sign(player.sprite.get_scale().x) == sign(sprite.get_scale().x)):
			disloge.x *= -1
		if (current_state == HURTING):
			#was already hurting when this attack hit, 
			#fly back with full force
			move_and_slide(disloge)
			ignore_z = true
			current_state = FALLING
			current_state_ctx.fall_direction = sign(disloge.x)
			current_state_ctx.fall_start_y = feet_pos.y
		else:
			#was not yet hurt when attack hit, 
			#push back half idstance and start hurting
			move_and_slide(Vector2(disloge.x / 2, 0))