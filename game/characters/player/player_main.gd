extends "../basic_movement.gd"

onready var movement = get_node("player_move")
onready var attacks = get_node("player_attack")
onready var catch_point = get_node("sprites/catch_point")
#generic timer counting gametime up during processing updates, in ms
var timer
var curr_anim
var next_anim

var caught_enemy
#nodes to perform additional processing when parent is ready
#normally children are inited before parent
onready var init_nodes = [
	movement,
	attacks
]

signal set_max_hp(max_hp)
signal set_health(health)

#states that represent when to ignore the input from attack and move scripts
var INDISPOSED_STATES = [
	HURTING,
	FALLING,
	FALLEN,
	DYING
]

func _ready():
	curr_anim = ""
	next_anim = null
	timer = 0.0
	MAX_HP = 150
	stun_regen_rate = 17.5
	attacks_hitboxes = get_node("sprites/attack_hitboxes")
	._ready()
	for node in init_nodes:
		if node.has_method("_parent_ready"):
			node._parent_ready()
	#get HUD elements and connect signals
	var hud = get_node("/root/level/overlay/HUD")
	if (hud != null):
		connect(CONST.SIG_PLAYER_MAX_HP, hud, "_set_max_hp")
		connect(CONST.SIG_PLAYER_SET_HP, hud, "_set_hp")
	
	emit_signal(CONST.SIG_PLAYER_MAX_HP, MAX_HP)
	set_health(MAX_HP)
	
func update_hurt_states(delta):
	.update_hurt_states(delta)
	set_hurt_animation()

func setup_body_slam():
	#attack specifics
	body_area.attack_info.attack_name = "body_area"
	body_area.attack_info.attack_stun = 100
	body_area.attack_info.attack_power = 20
	body_area.attack_info.attack_z = 3
	body_area.attack_info.hit_lock = 0.5
	body_area.attack_info.disloge_vector = Vector2(150,-25)
	
	if (attacks_hitboxes != null):
		attacks_hitboxes.attacks_hitboxes.append(body_area)
		print("Added %s to attacks list!" % body_area.attack_info)

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
	timer += delta

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
	
func _draw():
	._draw()
	draw_circle(catch_point.get_pos(), 5.0, COLOR_WHITE)
	
func set_health (health):
	.set_health(health)
	emit_signal(CONST.SIG_PLAYER_SET_HP, health)
	
func reset_state():
	.reset_state()
	if (attacks != null):
		attacks.reset_attack_state()

func set_hurt_animation():
	if (current_state == HURTING):
		next_anim = CONST.PLAYER_ANIM_HURTING
		#thug was already hurting, lets restart the animation
		if (anim.is_playing() and 
		anim.get_current_animation() == next_anim and
		just_hit):
			anim.play(next_anim)
	elif (current_state == FALLING):
		if current_state_ctx.fall_direction > 0:
			next_anim = CONST.PLAYER_ANIM_FALLING_FWD 
		else: 
			next_anim = CONST.PLAYER_ANIM_FALLING_BCK
			
	elif (current_state == FALLEN):
		if current_state_ctx.fall_direction > 0:
			next_anim = CONST.PLAYER_ANIM_ON_BACK
		else:
			next_anim = CONST.PLAYER_ANIM_ON_BELLY
	elif (current_state == DYING):
		if (!(next_anim in [CONST.PLAYER_ANIM_ON_BACK, CONST.PLAYER_ANIM_ON_BELLY])):
			#try evaluating again
			current_state = FALLEN
			set_hurt_animation()
			current_state = DYING
		#dying animation name is based on fallen animation name (on belly or on back)
		next_anim = "player_death_" + next_anim.right("player_fall_".length())