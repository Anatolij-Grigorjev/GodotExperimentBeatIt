#global util functions
#add var with line 
#  
#  onready var UTILS = get_node("/root/utils")
#
#to use
extends Node


func get_sprite_extents( sprite ):
	var tex_size = sprite.texture.get_size()
	var single_size = Vector2(tex_size.x / sprite.get_hframes(), tex_size.y / sprite.get_vframes())
	return single_size * 0.5
	