extends "../basic_movement.gd"

enum STATES {STANDING, MOVING, ATTACKING, HURTING}

export var current_state = STATES.STANDING
var current_decision_wait
var current_state_ctx = {}
var attacks = []
var current_anim
var getting_hit
#amount of time enemy is actively getting hit
#immune to further hits while this is happening
var hit_lock

onready var anim = get_node("movement/anim")
var player

#main defaults for enemies on things
export var decision_interval = 2.5 #in seconds
export var scan_distance = 350 # in pixels, to either side
export var attack_distance = 50
export var aggressiveness = 0.75 # in percentiles
export var movement_speed = Vector2(150, 50)


func _ready():
	current_state = STANDING
	current_state_ctx = {}
	current_decision_wait = decision_interval
	getting_hit = false
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
	
	#process movement limitations on level
	._process(delta)

func change_anim():
	pass
	
func change_state(delta):
	#hurting is an external state thing
	if (current_state != HURTING):
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
							current_state = MOVING
							current_state_ctx.direction = distance.normalized()
				
				pass
			elif (current_state == MOVING):
				
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
	else:
		getting_hit = hit_lock > 0
		if (getting_hit):
			hit_lock -= delta
		#currently hurting
		if (!getting_hit and !anim.is_playing()):
			#finished hurting and not being hurt no more,
			#so get back to standing and 
			#make another decision on the next frame
			current_state = STANDING
			current_decision_wait = 0
			
func take_action(delta):
	#take action based on elected state
	if (current_state == MOVING):
		set_pos(get_pos() + (current_state_ctx.direction * movement_speed * delta))
		if (current_state_ctx.direction.x < 0):
			set_scale(Vector2(-1.0, 1.0))
		elif (current_state_ctx.direction.x > 0):
			set_scale(Vector2(1.0, 1.0))
			
func set_random_attack_state(distance):
	current_state = ATTACKING
	current_state_ctx.direction = distance.normalized()
	current_state_ctx.attack = randi() % attacks.size()
		