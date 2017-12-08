extends "../../attack_hitboxes.gd"

func _ready():
	parent = get_node("../../")
	attacks_conf_file = CONST.THUG_ATTACKS_CONFIG_FILE_PATH
	enemy_group = CONST.GROUP_PLAYER
	._ready()