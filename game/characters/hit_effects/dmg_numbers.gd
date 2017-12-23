extends Node2D

const ASCEND_LIMIT = 65
onready var anim_player = get_node("anim")
onready var label = get_node("dmg_label")

var anim
var track_idx
var key_indices = []

func _ready():
	anim = anim_player.get_animation("ascend")
	track_idx = anim.find_track(NodePath(".:transform/pos"))
	for time in [0.0, 0.5]: 
		var key_idx = anim.track_find_key(track_idx, time, true)
		key_indices.append(key_idx)
	pass
	
#update naimation of dmg numbers node to include correct positin for track
func prepare_animation( label_text ):
	#add actual positions to animation
	for key_idx in key_indices:
		var key_val = anim.track_get_key_value(track_idx, key_idx)
		anim.track_set_key_value(track_idx, key_idx, key_val + get_pos())
	label.set_text(label_text)
	
func finish():
	anim.track_set_key_value(track_idx, key_indices[0], Vector2(0,0))
	anim.track_set_key_value(track_idx, key_indices[1], Vector2(0, -ASCEND_LIMIT))
	queue_free()
