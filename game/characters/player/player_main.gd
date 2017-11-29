extends "../basic_movement.gd"

onready var anim = get_node("anim")
onready var sprite = get_node("sprites")
onready var movement = get_node("player_move")
onready var attacks = get_node("player_attack")
onready var catch_point = get_node("sprites/catch_point")

var curr_anim
var next_anim

var caught_enemy
var getting_hit = false
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

func release_enemy(disloge = CONST.VECTOR2_ZERO):
	var enemy = caught_enemy
	if (enemy != null):
		caught_enemy = null
		enemy.set_pos_by_feet(feet_pos - Vector2(0, 1))
		enemy.feet_ground_y = feet_pos.y
		enemy.current_state_ctx.fall_start_y = feet_pos.y
		enemy.current_state = FALLING
		enemy.ignore_G = true
		enemy.ignore_z = true
		enemy.current_state_ctx.fall_direction = 1
		enemy.current_state_ctx.initial_pos = enemy.center_pos
		#make sure disloge happens in the right direction
		enemy.current_state_ctx.disloge = Vector2(
			disloge.x * sign(sprite.get_scale().x),
			disloge.y)

func get_hit(attack_info):
	pass
	
func _draw():
	._draw()
	draw_circle(catch_point.get_pos(), 5.0, COLOR_WHITE)