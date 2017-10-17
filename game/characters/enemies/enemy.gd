extends "../basic_movement.gd"

const DECISION_INTERVAL = 2.5 #in seconds

var getting_hit = false
var current_decision_wait

func _ready():
	current_decision_wait = DECISION_INTERVAL
	._ready()
	
func _process(delta):
	
	if (!getting_hit):
		#make deiscions
		current_decision_wait -= delta
		if (current_decision_wait < 0):
			#make decision
			current_decision_wait = DECISION_INTERVAL
		
	._process(delta)
