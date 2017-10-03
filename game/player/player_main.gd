extends Area2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var current_sprite
onready var movement = get_node("player_move")
onready var attacks = get_node("player_attack")
var move_extents = Vector2()
var attack_extents = Vector2()

export var feet_pos = Vector2()
export var min_pos = Vector2()
export var max_pos = Vector2()

func _ready():
	var move_sprite = movement.sprite
	var tex_size = move_sprite.texture.get_size()
	var single_size = Vector2(tex_size.x / move_sprite.get_hframes(), text_size.y / move_sprite.get_vframes())
	move_extents = single_size * 0.5
	set_process(true)

func _process(delta):
	var pos = get_pos()
	feet_pos = Vector2(pos.x, pos.y + move_extents.y)
	min_pos = Vector2(pos.x - move_extents.x, pos.y + move_extents.y)
	max_pos = Vector2(pos.x + move_extents.x, pos.y - move_extents.y)