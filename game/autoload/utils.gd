#global util functions
#add var with line 
#  
#  onready var UTILS = get_node("/root/utils")
#
#to use
extends Node

#load constants, they load sooner than this does
onready var CONST = get_node("/root/const")

var names = []

#init random names list
func _ready():
	var names_file = File.new()
	if (names_file.file_exists(CONST.FILE_PATH_NAMES_DB)):
		names_file.open(CONST.FILE_PATH_NAMES_DB, File.READ)
		while (!names_file.eof_reached()):
			var name = names_file.get_line().strip_edges()
			names.append(name)
		names_file.close()
		print("read " + str(names.size()) + " names from db file " + CONST.FILE_PATH_NAMES_DB)
	else:
		print("File doesnt exist at " + CONST.FILE_PATH_NAMES_DB)

func random_name():
	return names[randi() % names.size()]

func get_sprite_extents( sprite ):
	var tex_size = sprite.texture.get_size()
	var single_size = Vector2(tex_size.x / sprite.get_hframes(), tex_size.y / sprite.get_vframes())
	return single_size * 0.5
	
func json_to_dict( location ):
	var file = File.new()
	file.open(location, File.READ)
	var text = file.get_as_text()
	var data = {}
	data.parse_json(text)
	return data
	
func flip_sprite_dir( sprite ):
	var scale = sprite.get_scale()
	scale.x *= -1
	sprite.set_scale(scale)
	
func mirror_pos( node, axis = "both" ):
	var pos = node.get_pos()
	if (axis == "x"):
		pos.x *= -1
	elif (axis == "y"):
		pos.y *= -1
	else:
		pos *= -1
	node.set_pos(pos)

func sprites_facing(sprite1, sprite2):
	return sign(sprite1.get_scale().x) != sign(sprite2.get_scale().x)
	
func randomize_vec2( vector2, spread = 7.5 ):
	return Vector2(
		rand_range(vector2.x - spread, vector2.x + spread),
		rand_range(vector2.y - spread, vector2.y + spread)
	)

func randomize_num( number, spread = 5.0, min_max = Vector2( 1.0, 1.5e27 ) ):
	return clamp( rand_range( number - spread, number + spread ), min_max.x, min_max.y )
	
#decode string property value
func decode_serialized(value):
	#check known codes
	for code in ["!v;"]:
		if (value.begins_with(code)):
			var actual = value.substr(code.length(), value.length() - code.length())
			var nums = actual.split_floats("_")
			return Vector2(nums[0], nums[1])
	
	return value