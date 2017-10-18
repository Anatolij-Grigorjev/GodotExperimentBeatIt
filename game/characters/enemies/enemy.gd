extends "../basic_movement.gd"

const DECISION_INTERVAL = 2.5 #in seconds

enum STATES {STANDING, MOVING, ATTACKING, HURTING}

var current_state
var current_decision_wait

onready var anim = get_node("anim")

func _ready():
	current_state = STANDING
	current_decision_wait = DECISION_INTERVAL
	._ready()
	
func _process(delta):
	
	if (current_state != HURTING):
		#make deiscions
		current_decision_wait -= delta
		if (current_decision_wait < 0):
			#make decision, due to upper if, 
			#unlikely to be HURTING here
			if (current_state == STANDING):
				pass
			elif (current_state == MOVING):
				pass
			elif(current_state == ATTACKING):
				pass
			else:
				current_state = STANDING
			current_decision_wait = DECISION_INTERVAL
		
	._process(delta)
