extends "../basic_movement.gd"

enum STATES {STANDING, MOVING, ATTACKING, HURTING}

var current_state
var current_decision_wait
var current_state_ctx = {}
var attacks = []
var current_anim

onready var anim = get_node("anim")
onready var player = get_tree().get_root().find_node("player")

export var decision_interval = 2.5 #in seconds
export var scan_distance = 350 # in pixels, to either side
export var attack_distance = 50
export var movement_speed = Vector2(150, 50)


func _ready():
	current_state = STANDING
	current_state_ctx = {}
	current_decision_wait = decision_interval
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
	if (current_state == STANDING):
		current_anim = "idle"
	elif (current_state == MOVING):
		current_anim = "walking"
	elif(current_state == ATTACKING):
		current_anim = attacks[current_state_ctx.attack]
	pass	
	
func change_state(delta):
	#hurting is an external state thing
	if (current_state != HURTING):
		#make deiscions
		current_decision_wait -= delta
		if (current_decision_wait < 0):
			#make decision,
			#due to upper if unlikely to be HURTING here
			var distance = player.feet_pos - feet_pos
			if (current_state == STANDING):
				#scan area for player
				if (abs(distance.x) < scan_distance):
					if (abs(distance.x) < attack_distance):
						current_state = ATTACKING
						current_state_ctx.direction = distance.normalized()
						current_state_ctx.attack = randi() % attacks.size()
					else:
						current_state = MOVING
						current_state_ctx.direction = distance.normalized()
				
				pass
			elif (current_state == MOVING):
				
				if (abs(distance.x) < attack_distance):
					current_state = ATTACKING
					current_state_ctx.direction = distance.normalized()
					current_state_ctx.attack = randi() % attacks.size()
				pass
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
	if (current_state == MOVING):
		set_pos(get_pos() + (current_state_ctx.direction * movement_speed * delta))
		if (current_state_ctx.direction.x < 0):
			set_scale(Vector2(-1.0, 1.0))
		elif (current_state_ctx.direction.x > 0):
			set_scale(Vector2(1.0, 1.0))
	elif (current_state == ATTACKING):
		pass
		