extends "../basic_movement.gd"

onready var anim = get_node("anim")
var curr_anim
var next_anim

#nodes to perform additional processing when parent is ready
#normally children are inited before parent
onready var init_nodes = [
	get_node("player_move"),
	get_node("player_attack")
]

func _ready():
	curr_anim = ""
	next_anim = null
	._ready()
	for node in init_nodes:
		if node.has_method("_parent_ready"):
			node._parent_ready()

func _process(delta):
	curr_anim = anim.get_current_animation()
	._process(delta)
	#only apply another animation if its different and was changed
	if (curr_anim != next_anim and next_anim != null):
		curr_anim = next_anim
		anim.play(curr_anim)
	#clear at end of frame
	next_anim = null