extends Area2D

#quick access to constnats
onready var CONST = get_node("/root/const")
onready var UTILS = get_node("/root/utils")

onready var parent = get_node("../../")

onready var CATCHING_STATES = [
	parent.WALKING,
	parent.RUNNING
]

var last_known_body = null
#idle holding of catch, in seconds
const CATCH_HOLD_DURATION = 1.0

func _ready():
	set_process(true)
	
func _process(delta):
	#already holding somebody, cant hold 2 guys at once
	if ( parent.caught_enemy != null ):
		return
	#nobody in the vicinity, nothing to process
	if (last_known_body == null):
		return
	process_caught_body()

func process_caught_body():
	#only try to catch enemies
	if ( !last_known_body.is_in_group(CONST.GROUP_ENEMIES) ):
		return
	#already holding the guy
	if ( last_known_body == parent.caught_enemy ):
		return
	#can only grab currently hurting enemies
	if ( last_known_body.current_state != parent.HURTING ):
		return
	#if the player is walking towards the enemy, not standing there attacking
	if ( parent.current_state in CATCHING_STATES): 
		#set the porper states
		last_known_body.current_state = parent.CAUGHT
		last_known_body.getting_hit = false
		#make caught enemy face player
		if (!UTILS.sprites_facing(parent.sprite, last_known_body.sprite)):
			UTILS.flip_sprite_dir(last_known_body.sprite)
		parent.current_state = parent.CATCHING
		#setup max combo cooldown
		parent.next_anim = CONST.PLAYER_ANIM_CATCHING
		parent.attacks.current_combo_countdown = CATCH_HOLD_DURATION
		parent.caught_enemy = last_known_body
		var global_catch_pos = parent.catch_point.get_global_pos()
		last_known_body.set_global_pos(Vector2(global_catch_pos.x, parent.center_pos.y))

func _on_catch_point_body_enter( body ):
	#collision with own body
	if ( body == parent ):
		return
	last_known_body = body
	