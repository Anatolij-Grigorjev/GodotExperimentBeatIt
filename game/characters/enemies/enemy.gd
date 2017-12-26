extends "../basic_movement.gd"

var current_decision_wait

var attacks = []
var current_anim

onready var healthbar = get_node("healthbar")
var player
#main defaults for enemies on things
export var decision_interval = 2.5 #in seconds
export var scan_distance = 350 # in pixels, to either side
export var attack_distance = 50 #in pixels, either side
export var aggressiveness = 0.75 # in percentiles
export var movement_speed = Vector2(150, 50)

#enemy death signal, connected to pool before death
signal enemy_death(idx)

func _ready():
	reset_state()
	healthbar.set_min( 0 )
	healthbar.set_max( MAX_HP )
	set_health(MAX_HP)
	player = get_tree().get_root().find_node("player", true, false)
	._ready()
	
func _process(delta):
	move_vector = CONST.VECTOR2_ZERO
	._process(delta)
	if (player != null):

		change_state(delta)
		take_action(delta)
	
		if (current_anim != anim.get_current_animation()):
			anim.play(current_anim)
	change_anim()
	
	#integrate new position
	var new_pos = get_pos() + (move_vector * delta)
	set_pos(new_pos)

func change_anim():
	pass
	
func reset_state(action_wait = decision_interval):
	.reset_state()
	current_decision_wait = action_wait
	
func change_state(delta):
	if ((current_state in HURTING_STATES) 
	or (current_state in CAUGHT_STATES)
	or (current_state in FALLING_STATES)):
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
		if (current_state_ctx.direction.x != 0):
			set_direction(sign(current_state_ctx.direction.x))

#default implementation for enemy is to pick a random attack
func set_attack_state(distance):
	set_random_attack_state(distance)

func set_random_attack_state(distance):
	current_state = ATTACKING
	current_state_ctx.direction = distance.normalized()
	current_state_ctx.attack = randi() % attacks.size()

func connect_pool_signal( pool ):
	connect(CONST.SIG_ENEMY_DEATH, pool, "_enemy_dead")

func dying():
	print("Enemy %s dead!" % self)
	remove_from_group(CONST.GROUP_ENEMIES)
	emit_signal(CONST.SIG_ENEMY_DEATH, self)
	queue_free()

func set_health( health ):
	.set_health( health )
	healthbar.set_value( health )
