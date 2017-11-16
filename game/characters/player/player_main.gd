extends "../basic_movement.gd"

onready var anim = get_node("anim")
onready var sprite = get_node("sprites")
onready var movement = get_node("player_move")
onready var attacks = get_node("player_attack")
onready var catch_point = get_node("catch_point")

var curr_anim
var next_anim

var caught_enemy

#nodes to perform additional processing when parent is ready
#normally children are inited before parent
onready var init_nodes = [
	movement,
	attacks
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
	#integrate new position
	var new_pos = get_pos() + (move_vector * delta)
	set_pos(new_pos)
	#also add posirion to caugh enemy
	if (caught_enemy != null):
		caught_enemy.set_pos(catch_point.get_pos() + new_pos)